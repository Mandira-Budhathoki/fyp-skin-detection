import os
import cv2
import torch
import numpy as np
import tensorflow as tf
from PIL import Image
from transformers import ViTImageProcessor, ViTForImageClassification, AutoImageProcessor, AutoModelForImageClassification
import torchvision.transforms as T
import torch.nn.functional as F

class FaceHealthAnalyzer:
    def __init__(self):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.hf_dir = os.path.join(self.base_dir, "ai_models", "hf_models")
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
        # 0. Limit TensorFlow Memory Growth (Prevent TF from hogging all GPU memory)
        if self.device == "cuda":
            gpus = tf.config.list_physical_devices('GPU')
            if gpus:
                try:
                    for gpu in gpus:
                        tf.config.experimental.set_memory_growth(gpu, True)
                    print("[SYSTEM] TensorFlow Memory Growth Enabled.")
                except RuntimeError as e:
                    print(f"[ERROR] TF Memory Growth configuration failed: {e}")

        print(f"[SYSTEM] Initializing Face Health Analyzer Ensemble on {self.device}...")

        # 1. Load HuggingFace ViT Models (Skin Type, Acne, Gender, Emotion)
        self.models = {}
        self.processors = {}
        
        self.vit_configs = {
            "skin_type":   "skin_type",
            "acne":        "acne_severity",
            "gender":      "gender",
            "emotion":     "emotions"
        }
        
        for key, folder in self.vit_configs.items():
            path = os.path.join(self.hf_dir, folder)
            try:
                print(f"  📦 Loading {key} model...")
                self.processors[key] = AutoImageProcessor.from_pretrained(path)
                self.models[key] = AutoModelForImageClassification.from_pretrained(path).to(self.device)
                self.models[key].eval()
            except Exception as e:
                print(f"  ⚠️ Failed to load {key}: {e}")

        # 2. Load Spots Model (ResNet with State Map logic)
        try:
            print("  📦 Loading spots model (ResNet)...")
            spots_path = os.path.join(self.hf_dir, "spots")
            import torchvision.models as tv_models
            
            # The current weights are torchvision-style (layer1, layer2...)
            # But AutoModelForImageClassification expects transformers-style.
            # We will use the torchvision architecture directly to match the weights.
            self.models["spots"] = tv_models.resnet50(weights=None)
            self.models["spots"].fc = torch.nn.Linear(self.models["spots"].fc.in_features, 4)
            
            # Load weights manually
            weights_file = os.path.join(spots_path, "pytorch_model.bin")
            if not os.path.exists(weights_file):
                weights_file = os.path.join(spots_path, "model.safetensors") # Try safe tensors
            
            if os.path.exists(weights_file):
                if weights_file.endswith(".bin"):
                    state_dict = torch.load(weights_file, map_location="cpu")
                else: 
                    from safetensors.torch import load_file
                    state_dict = load_file(weights_file)
                
                # Fix key prefix if it has "resnet." or "model." from a different export
                clean_state_dict = {}
                for k, v in state_dict.items():
                    # Handle "resnet." or "model." prefixes if they exist
                    new_key = k.replace("resnet.", "").replace("model.", "")
                    clean_state_dict[new_key] = v
                
                self.models["spots"].load_state_dict(clean_state_dict, strict=False)
                print("    ✅ Spots weights mapped and loaded.")
            
            self.models["spots"] = self.models["spots"].to(self.device)
            self.models["spots"].eval()
            
            # Spots preprocess transform
            self.spots_transform = T.Compose([
                T.Resize((224, 224)),
                T.ToTensor(),
                T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ])
            self.spots_classes = ["Clear", "Mild Spots", "Moderate Spots", "Severe Spots"]
            
        except Exception as e:
            print(f"  ⚠️ Failed to load spots model: {e}")

        # 3. Load Inflammation Model (Keras/Tensorflow)
        try:
            print("  📦 Loading inflammation model (DermaAI)...")
            inf_path = os.path.join(self.hf_dir, "inflammation", "DermaAI.keras")
            self.models["inflammation"] = tf.keras.models.load_model(inf_path, compile=False)
            self.inf_classes = [
                'Healthy / No Inflammation', # Mapping based on README
                'Eczema / Inflamed', 
                'Psoriasis / Scaly',
                'Seborrheic Keratoses',
                'Tinea Ringworm'
            ]
        except Exception as e:
            print(f"  ⚠️ Failed to load inflammation model: {e}")

        # 4. Load Face Shape Model (Custom PyTorch)
        try:
            print("  📦 Loading face shape model...")
            fs_path = os.path.join(self.hf_dir, "face_shape", "model_85_nn_.pth")
            # FIXED: Explicitly set weights_only=False for compatibility with newer PyTorch versions
            # Some models are saved as full objects and require pickling support.
            self.models["face_shape"] = torch.load(fs_path, map_location=torch.device('cpu'), weights_only=False).to(self.device)
            self.models["face_shape"].eval()
            self.fs_classes = ['Heart', 'Oblong', 'Oval', 'Round', 'Square']
            self.fs_transform = T.Compose([
                T.Resize((224, 224)),
                T.ToTensor(),
                T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ])
        except Exception as e:
            print(f"  ⚠️ Failed to load face shape model: {e}")

        # 5. Load Face Detection (OpenCV)
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        self.face_cascade = cv2.CascadeClassifier(cascade_path)

        print("[SUCCESS] Ensemble initialized.")

    def preprocess_face(self, image_path):
        """Detects face and crops properly. Fallback to center crop if no face found."""
        img_bgr = cv2.imread(image_path)
        if img_bgr is None: return None, None
        
        img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
        gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
        
        # We try to find the face with stricter parameters to avoid books/patterns
        faces = self.face_cascade.detectMultiScale(gray, 1.3, 6)
        
        if len(faces) > 0:
            # Pick largest face
            (x, y, w, h) = max(faces, key=lambda f: f[2]*f[3])
            
            # Add 20% padding
            padding_w = int(w * 0.2)
            padding_h = int(h * 0.2)
            
            x1 = max(0, x - padding_w)
            y1 = max(0, y - padding_h)
            x2 = min(img_rgb.shape[1], x + w + padding_w)
            y2 = min(img_rgb.shape[0], y + h + padding_h)
            
            face_crop = img_rgb[y1:y2, x1:x2]
            return Image.fromarray(face_crop), img_rgb, True
        
        # 🟢 FALLBACK: If no face detected, we return False
        return None, img_rgb, False

    def analyze_stream(self, image_path):
        yield {"progress": "Processing image..."}
        face_img, full_img_rgb, face_detected = self.preprocess_face(image_path)
        
        if not face_detected:
            yield {"error": "No Face Detected", "message": "We could not detect a face. Please ensure your face is well-lit and clearly visible.", "status": "fail"}
            return
        
        if face_img is None:
            yield {"error": "Could not read image", "status": "fail"}
            return

        yield {"progress": "Face verified, starting ensemble..."}

        # 🛡️ FACE INTEGRITY CHECK SCALE
        # We track how many models are "confused" to detect books/objects
        confused_models = 0
        total_required_models = 3 # Skin type, Gender, Emotion
        CONF_THRESHOLD = 25.0 

        results = {
            "skin_type": {"label": "Analyzing...", "confidence": 0.0},
            "acne": {"label": "Analyzing...", "confidence": 0.0},
            "spots": {"label": "Analyzing...", "confidence": 0.0},
            "inflammation": {"label": "Analyzing...", "confidence": 0.0},
            "face_shape": {"label": "Analyzing...", "confidence": 0.0},
            "gender": {"label": "Analyzing...", "confidence": 0.0},
            "emotion": {"label": "Analyzing...", "confidence": 0.0},
            "status": "success"
        }

        vit_tasks = ["skin_type", "acne", "gender", "emotion"]
        for key in vit_tasks:
            if key in self.models:
                try:
                    yield {"progress": f"ANALYZING {key.upper().replace('_', ' ')}..."}
                    inputs = self.processors[key](images=face_img, return_tensors="pt").to(self.device)
                    with torch.no_grad():
                        outputs = self.models[key](**inputs)
                        probs = F.softmax(outputs.logits, dim=-1)
                        conf, idx = torch.max(probs, dim=-1)
                        
                        id2label = self.models[key].config.id2label
                        idx_item = idx.item()
                        
                        if idx_item in id2label:
                            raw_label = id2label[idx_item]
                        elif str(idx_item) in id2label:
                            raw_label = id2label[str(idx_item)]
                        else:
                            raw_label = f"Class {idx_item}"

                        raw_conf = round(float(conf.item()) * 100, 2)

                        # If key models are very low, we increment the confusion counter
                        if key in ["gender", "skin_type", "emotion"] and raw_conf < 35:
                            confused_models += 1

                        if raw_conf < CONF_THRESHOLD:
                            label = "Inconclusive / Retake"
                        else:
                            label = raw_label
                            if key == "acne":
                                mapping = {
                                    "level -1": "Clear Skin", "level 0": "Occasional Spots",
                                    "level 1": "Mild Acne", "level 2": "Moderate Acne",
                                    "level 3": "Severe Acne", "level 4": "Very Severe Acne"
                                }
                                label = mapping.get(label, label)
                        
                        results[key] = {"label": label, "confidence": raw_conf}
                except Exception as e:
                    print(f"[ERROR] Inference failed for {key}: {e}")
                    results[key] = {"label": "Engine Offline", "confidence": 0.0}
            else:
                results[key] = {"label": "Not Loaded", "confidence": 0.0}

        # 🛡️ THE FINAL FACE GUARD
        # If all major face-identifying models are confused, it's likely an object (like a book)
        if confused_models >= 3:
            yield {"error": "Invalid Face Image", "message": "The AI is unable to verify this is a human face. Please ensure the camera is level and clear.", "status": "fail"}
            return

        # 🟢 NEW: Separate SPOTS logic (Custom ResNet)
        if "spots" in self.models:
            try:
                yield {"progress": "SEARCHING FOR SPOTS & PORES..."}
                face_tensor = self.spots_transform(face_img).unsqueeze(0).to(self.device)
                with torch.no_grad():
                    outputs = self.models["spots"](face_tensor)
                    probs = F.softmax(outputs, dim=1)
                    conf, idx = torch.max(probs, 1)
                    raw_conf = round(float(conf.item()) * 100, 2)
                    label = self.spots_classes[idx.item()] if idx.item() < len(self.spots_classes) else "Unknown"
                    results["spots"] = {"label": label, "confidence": raw_conf}
            except Exception as e:
                print(f"[ERROR] Inference failed for spots: {e}")
                results["spots"] = {"label": "Engine Offline", "confidence": 0.0}

        if "inflammation" in self.models:
            try:
                yield {"progress": "EVALUATING INFLAMMATION..."}
                prep_img = face_img.resize((224, 224))
                img_array = np.array(prep_img)
                img_array = tf.keras.applications.efficientnet_v2.preprocess_input(img_array)
                img_array = np.expand_dims(img_array, axis=0)
                
                preds = self.models["inflammation"].predict(img_array, verbose=0)[0]
                idx = np.argmax(preds)
                raw_conf = round(float(preds[idx]) * 100, 2)
                
                if raw_conf < CONF_THRESHOLD:
                    label = "Inconclusive"
                else:
                    label = self.inf_classes[idx] if idx < len(self.inf_classes) else "Skin Issue"

                results["inflammation"] = {"label": label, "confidence": raw_conf}
            except Exception as e:
                print(f"[ERROR] Inference failed for inflammation: {e}")
                results["inflammation"] = {"label": "Engine Offline", "confidence": 0.0}
        else:
            results["inflammation"] = {"label": "Not Loaded", "confidence": 0.0}

        if "face_shape" in self.models:
            try:
                yield {"progress": "IDENTIFYING FACE SHAPE..."}
                face_tensor = self.fs_transform(face_img).unsqueeze(0).to(self.device)
                with torch.no_grad():
                    outputs = self.models["face_shape"](face_tensor)
                    probs = F.softmax(outputs, dim=1)
                    conf, idx = torch.max(probs, 1)
                    
                    raw_conf = round(float(conf.item()) * 100, 2)
                    if raw_conf < (CONF_THRESHOLD - 10):
                        label = "Inconclusive"
                    else:
                        label = self.fs_classes[idx.item()]

                    results["face_shape"] = {"label": label, "confidence": raw_conf}
            except Exception as e:
                print(f"[ERROR] Inference failed for face_shape: {e}")
                results["face_shape"] = {"label": "Engine Offline", "confidence": 0.0}
        else:
            results["face_shape"] = {"label": "Not Loaded", "confidence": 0.0}

        yield {"progress": "FINALIZING REPORT..."}
        yield {"result": results}

    def analyze(self, image_path, progress_callback=None):
        if progress_callback: progress_callback("Processing image...")
        face_img, full_img_rgb, face_detected = self.preprocess_face(image_path)
        
        if not face_detected:
            return {"error": "No Face Detected", "message": "No clear face found in the image. Please retake the photo.", "status": "fail"}

        if face_img is None:
            return {"error": "Could not read image", "status": "fail"}

        if progress_callback: progress_callback("Face verified, starting ensemble...")

        # 🛡️ FACE INTEGRITY CHECK
        confused_models = 0
        CONF_THRESHOLD = 25.0 

        results = {
            "skin_type": {"label": "Analyzing...", "confidence": 0.0},
            "acne": {"label": "Analyzing...", "confidence": 0.0},
            "spots": {"label": "Analyzing...", "confidence": 0.0},
            "inflammation": {"label": "Analyzing...", "confidence": 0.0},
            "face_shape": {"label": "Analyzing...", "confidence": 0.0},
            "gender": {"label": "Analyzing...", "confidence": 0.0},
            "emotion": {"label": "Analyzing...", "confidence": 0.0},
            "status": "success"
        }

        # 2. Run ViT Inference
        vit_tasks = ["skin_type", "acne", "gender", "emotion"]
        for key in vit_tasks:
            if key in self.models:
                try:
                    if progress_callback: progress_callback(f"Running {key.replace('_', ' ')} model...")
                    inputs = self.processors[key](images=face_img, return_tensors="pt").to(self.device)
                    with torch.no_grad():
                        outputs = self.models[key](**inputs)
                        probs = F.softmax(outputs.logits, dim=-1)
                        conf, idx = torch.max(probs, dim=-1)
                        
                        # FIXED: Handle both integer and string keys for id2label (HuggingFace quirk)
                        id2label = self.models[key].config.id2label
                        idx_item = idx.item()
                        
                        if idx_item in id2label:
                            raw_label = id2label[idx_item]
                        elif str(idx_item) in id2label:
                            raw_label = id2label[str(idx_item)]
                        else:
                            raw_label = f"Class {idx_item}"

                        raw_conf = round(float(conf.item()) * 100, 2)

                        # Counter for non-human object detection
                        if key in ["gender", "skin_type", "emotion"] and raw_conf < 35:
                            confused_models += 1

                        # Check Threshold
                        if raw_conf < CONF_THRESHOLD:
                            label = "Inconclusive / Retake"
                        else:
                            label = raw_label
                            # Special mapping for Acne Severity levels
                            if key == "acne":
                                mapping = {
                                    "level -1": "Clear Skin", "level 0": "Occasional Spots",
                                    "level 1": "Mild Acne", "level 2": "Moderate Acne",
                                    "level 3": "Severe Acne", "level 4": "Very Severe Acne"
                                }
                                label = mapping.get(label, label)
                        
                        results[key] = {
                            "label": label,
                            "confidence": raw_conf
                        }
                except Exception as e:
                    print(f"[ERROR] Inference failed for {key}: {e}")
                    results[key] = {"label": "Engine Offline", "confidence": 0.0}
            else:
                results[key] = {"label": "Not Loaded", "confidence": 0.0}

        # 🛡️ THE FINAL FACE GUARD
        if confused_models >= 3:
            return {"error": "Invalid Face Image", "message": "The AI is unable to verify this is a human face. Please try again with better framing.", "status": "fail"}

        # 🟢 NEW: SPOTS / PORES (Custom ResNet)
        if "spots" in self.models:
            try:
                if progress_callback: progress_callback("Searching for spots...")
                face_tensor = self.spots_transform(face_img).unsqueeze(0).to(self.device)
                with torch.no_grad():
                    outputs = self.models["spots"](face_tensor)
                    probs = F.softmax(outputs, dim=1)
                    conf, idx = torch.max(probs, 1)
                    raw_conf = round(float(conf.item()) * 100, 2)
                    label = self.spots_classes[idx.item()] if idx.item() < len(self.spots_classes) else "Unknown"
                    results["spots"] = {"label": label, "confidence": raw_conf}
            except Exception as e:
                print(f"[ERROR] Inference failed for spots: {e}")
                results["spots"] = {"label": "Engine Offline", "confidence": 0.0}

        # 3. Keras Inference (Inflammation)
        if "inflammation" in self.models:
            try:
                prep_img = face_img.resize((224, 224))
                img_array = np.array(prep_img)
                img_array = tf.keras.applications.efficientnet_v2.preprocess_input(img_array)
                img_array = np.expand_dims(img_array, axis=0)
                
                preds = self.models["inflammation"].predict(img_array, verbose=0)[0]
                idx = np.argmax(preds)
                raw_conf = round(float(preds[idx]) * 100, 2)
                
                if raw_conf < CONF_THRESHOLD:
                    label = "Inconclusive"
                else:
                    label = self.inf_classes[idx] if idx < len(self.inf_classes) else "Skin Issue"

                results["inflammation"] = {
                    "label": label,
                    "confidence": raw_conf
                }
            except Exception as e:
                print(f"[ERROR] Inference failed for inflammation: {e}")
                results["inflammation"] = {"label": "Engine Offline", "confidence": 0.0}
        else:
            results["inflammation"] = {"label": "Not Loaded", "confidence": 0.0}

        # 4. Custom PyTorch (Face Shape)
        if "face_shape" in self.models:
            try:
                face_tensor = self.fs_transform(face_img).unsqueeze(0).to(self.device)
                with torch.no_grad():
                    outputs = self.models["face_shape"](face_tensor)
                    probs = F.softmax(outputs, dim=1)
                    conf, idx = torch.max(probs, 1)
                    
                    raw_conf = round(float(conf.item()) * 100, 2)
                    if raw_conf < (CONF_THRESHOLD - 10): # Face shape models can have lower confidence
                        label = "Inconclusive"
                    else:
                        label = self.fs_classes[idx.item()]

                    results["face_shape"] = {
                        "label": label,
                        "confidence": raw_conf
                    }
            except Exception as e:
                print(f"[ERROR] Inference failed for face_shape: {e}")
                results["face_shape"] = {"label": "Engine Offline", "confidence": 0.0}
        else:
            results["face_shape"] = {"label": "Not Loaded", "confidence": 0.0}

        return results

if __name__ == "__main__":
    analyzer = FaceHealthAnalyzer()
    # test_img = "test.jpg"
    # if os.path.exists(test_img):
    #     res = analyzer.analyze(test_img)
    #     print(res)
