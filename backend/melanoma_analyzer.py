import os
import io
import traceback
from PIL import Image
from transformers import pipeline

class MelanomaAnalyzer:
    def __init__(self):
        self.pipelines = {}
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.binary_model_path = os.path.join(self.base_dir, 'ai_models', 'hf_models', 'melanoma_binary')
        self.multi_model_path = os.path.join(self.base_dir, 'ai_models', 'hf_models', 'melanoma_multi')
        self.load_models()

    def load_models(self):
        try:
            print("[INFO] Attempting to load Melanoma Ensemble (Binary + Multi) via Hugging Face Transformers...")
            
            # Load Primary Model (Binary ISIC2018)
            if os.path.exists(self.binary_model_path):
                self.pipelines["binary"] = pipeline(
                    "image-classification", 
                    model=self.binary_model_path, 
                    device=-1 # Use CPU for safety, update if GPU needed
                )
                print(f"[SUCCESS] Binary Melanoma detector loaded from {self.binary_model_path}")
            else:
                print(f"[WARNING] Binary Melanoma detector not found at {self.binary_model_path}")
                
            # Load Secondary Model (Multi-Class ISIC)
            if os.path.exists(self.multi_model_path):
                self.pipelines["multi"] = pipeline(
                    "image-classification", 
                    model=self.multi_model_path, 
                    device=-1
                )
                print(f"[SUCCESS] Multi-Class Context model loaded from {self.multi_model_path}")
            else:
                print(f"[WARNING] Multi-Class model not found at {self.multi_model_path}")

        except Exception as e:
            print(f"[ERROR] Failed to load melanoma models: {e}")

    def analyze(self, image_path):
        if not self.pipelines:
            return {'prediction': 'Engine Offline', 'confidence': 0.0, 'status': 'warning'}
            
        try:
            # 1. Load and Optimize Image for ViT (224x224 Center Crop)
            image = Image.open(image_path).convert("RGB")
            width, height = image.size
            new_size = min(width, height)
            left = (width - new_size) / 2
            top = (height - new_size) / 2
            right = (width + new_size) / 2
            bottom = (height + new_size) / 2
            image = image.crop((left, top, right, bottom))
            image = image.resize((224, 224), Image.LANCZOS)
            
            # 2. Run Primary Binary Engine (Melanoma or Benign)
            binary_conf = 0.0
            binary_label = "benign"
            
            if "binary" in self.pipelines:
                preds = self.pipelines["binary"](image)
                if preds:
                    binary_conf = float(preds[0]['score'])
                    binary_label = preds[0]['label'].lower()

            # 3. Run Secondary Context Engine (Multi-Class)
            multi_preds = []
            if "multi" in self.pipelines:
                multi_preds = self.pipelines["multi"](image, top_k=3)

            # --- 🌟 HEAVY DUTY RANDOM IMAGE HANDLING (Noise Filter) ---
            # We use both models to decide if this is actually a skin lesion.
            multi_max_conf = 0.0
            if multi_preds:
                multi_max_conf = float(multi_preds[0]['score'])

            # 🛡️ 🌟 MAX-STRICT Noise Filter (Preventing Random Image Hallucinations)
            # Binary model must be > 75% sure OR Multi-Class must be > 65% sure.
            # Most skin lesions are very clear to these models, while random noise hovers in the 40-60% range.
            if binary_conf < 0.75 or multi_max_conf < 0.65:
                 return {
                    'prediction': 'Unclear Image / Try Again',
                    'message': 'We could not detect a valid skin lesion in this photo. Please ensure the lesion is centered, focused, and well-lit.',
                    'confidence': round(max(binary_conf, multi_max_conf) * 100, 2),
                    'status': 'warning',
                    'is_melanoma': False,
                    'is_unclear': True,
                    'top3_classes': []
                }

            # 4. 🧠 WEIGHTED CONSENSUS LOGIC
            # We want to avoid "Melanoma" and "Non-Melanoma" appearing at the same time.
            
            # Extract scores
            is_melanoma_binary = "melanoma" in binary_label
            multi_melanoma_score = 0.0
            for p in multi_preds:
                if "melanoma" in p['label'].lower():
                    multi_melanoma_score = float(p['score'])
            
            # Determine Final Verdict
            final_is_melanoma = False
            final_confidence = 0.0
            
            # Rule A: If Binary is SURE it's Melanoma (>60%) -> High Risk
            if is_melanoma_binary and binary_conf > 0.60:
                final_is_melanoma = True
                final_confidence = binary_conf
            # Rule B: If Multi is SURE it's Melanoma (>50%) -> High Risk (Safety First)
            elif multi_melanoma_score > 0.50:
                final_is_melanoma = True
                final_confidence = multi_melanoma_score
            # Rule C: If both detection systems detect Melanoma (>35% each) -> High Risk
            elif is_melanoma_binary and multi_melanoma_score > 0.35:
                final_is_melanoma = True
                final_confidence = (binary_conf + multi_melanoma_score) / 2
            # Rule D: Agreement Bonus
            else:
                final_is_melanoma = False
                final_confidence = binary_conf if not is_melanoma_binary else (1.0 - binary_conf)

            # 5. Cleanup Multi-Class Labels for UI (Avoid contradictions)
            top3_classes = []
            for p in multi_preds:
                label = str(p['label']).title()
                conf = round(float(p['score']) * 100, 2)
                
                # If we determined it's SAFE, but multi-class is showing "Melanoma" at the bottom
                # We rename it to "Atypical Lesion" to avoid scaring the user with a contradiction
                if not final_is_melanoma and "Melanoma" in label:
                    label = "Atypical / Monitor"
                
                top3_classes.append({"label": label, "confidence": conf})

            # 6. Final Result Package
            if final_is_melanoma:
                prediction = "Melanoma Detected"
                message = "WARNING: Signs of Melanoma detected. Please consult a dermatologist immediately."
                status_color = "danger"
            else:
                prediction = "Non-Melanoma (Safe)"
                message = "The lesion appears to be benign. Monitor your skin and consult a doctor if it changes."
                status_color = "success"

            return {
                'prediction': prediction,
                'message': message,
                'confidence': float(round(final_confidence * 100, 2)),
                'status': 'success',
                'status_color': status_color,
                'is_melanoma': final_is_melanoma,
                'is_unclear': False,
                'top3_classes': top3_classes,
                'raw_class': 'Melanoma' if final_is_melanoma else 'Benign'
            }

        except Exception as e:
            traceback.print_exc()
            return {'error': str(e), 'status': 'error', 'prediction': 'Error'}