import os
import io
import traceback
import cv2
import numpy as np
from PIL import Image
from transformers import pipeline

class MelanomaAnalyzer:
    def __init__(self):
        self.pipelines = {}
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.binary_model_path = os.path.join(self.base_dir, 'ai_models', 'hf_models', 'melanoma_binary')
        self.multi_model_path = os.path.join(self.base_dir, 'ai_models', 'hf_models', 'melanoma_multi')

        # OpenCV face cascade for pre-screening
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        self.face_cascade = cv2.CascadeClassifier(cascade_path)

        self.load_models()

    def load_models(self):
        try:
            print("[INFO] Loading Melanoma Models...")

            if os.path.exists(self.binary_model_path):
                self.pipelines["binary"] = pipeline(
                    "image-classification",
                    model=self.binary_model_path,
                    device=-1
                )
                print(f"[SUCCESS] Binary Melanoma detector loaded.")
            else:
                print(f"[WARNING] Binary model not found at {self.binary_model_path}")

            if os.path.exists(self.multi_model_path):
                self.pipelines["multi"] = pipeline(
                    "image-classification",
                    model=self.multi_model_path,
                    device=-1
                )
                print(f"[SUCCESS] Multi-Class model loaded.")
            else:
                print(f"[WARNING] Multi-Class model not found at {self.multi_model_path}")

        except Exception as e:
            print(f"[ERROR] Failed to load melanoma models: {e}")

    # ─────────────────────────────────────────────
    #  IMAGE VALIDATION GUARDS
    # ─────────────────────────────────────────────

    def _has_face(self, image_path):
        """Detects if the image contains a human face."""
        try:
            img = cv2.imread(image_path)
            if img is None:
                return False
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = self.face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)
            return len(faces) > 0
        except Exception:
            return False

    def _has_skin_tones(self, image_path):
        """
        Checks if the image has enough skin-toned pixels.
        Real skin lesion photos ALWAYS contain significant skin-colored area.
        Random objects (food, walls, animals) usually fail this.
        """
        try:
            img = cv2.imread(image_path)
            if img is None:
                return False
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

            # Skin tone range in HSV (covers light to dark skin tones)
            lower1 = np.array([0,  20, 70],  dtype=np.uint8)
            upper1 = np.array([20, 255, 255], dtype=np.uint8)
            lower2 = np.array([170, 20, 70],  dtype=np.uint8)
            upper2 = np.array([180, 255, 255], dtype=np.uint8)

            mask1 = cv2.inRange(hsv, lower1, upper1)
            mask2 = cv2.inRange(hsv, lower2, upper2)
            skin_mask = cv2.bitwise_or(mask1, mask2)

            total_pixels = img.shape[0] * img.shape[1]
            skin_pixels = int(np.sum(skin_mask > 0))
            skin_ratio = skin_pixels / total_pixels

            print(f"[GUARD] Skin ratio: {skin_ratio:.2%}")
            return skin_ratio >= 0.15 # At least 15% skin-toned
        except Exception:
            return True # Fallback

    def _is_valid_lesion(self, all_preds, binary_conf):
        """
        Uses multiple signals to determine if the image is actually a skin lesion:
        1. Binary model confidence must be strong (>= 0.70)
        2. Multi-class top prediction must be decisive (>= 0.55)
        3. Predictions must not be spread too evenly (low entropy = confident = real lesion)
        """
        if not all_preds:
            return False

        top_conf = float(all_preds[0]['score'])

        # GUARD 1: Multi-class top prediction too weak
        if top_conf < 0.55:
            return False

        # GUARD 2: Binary model not confident at all (random object)
        if binary_conf < 0.70:
            return False

        # GUARD 3: Entropy check — if predictions are spread evenly, it's random
        scores = [float(p['score']) for p in all_preds]
        entropy = -sum(s * np.log(s + 1e-10) for s in scores)
        max_entropy = -np.log(1.0 / len(scores))  # worst case = uniform
        normalized_entropy = entropy / (max_entropy + 1e-10)

        # If entropy is very high (> 0.85), the model is "confused" = not a real lesion
        if normalized_entropy > 0.85:
            return False

        return True

    # ─────────────────────────────────────────────
    #  MAIN ANALYSIS
    # ─────────────────────────────────────────────

    def analyze(self, image_path):
        if not self.pipelines:
            return {'prediction': 'Engine Offline', 'confidence': 0.0, 'status': 'warning'}

        # Build the rejection response (reused for all invalid cases)
        INVALID_RESPONSE = {
            'prediction': 'Invalid Image',
            'message': 'This does not appear to be a skin lesion photo. Please upload a clear, close-up image of a specific mole or skin spot.',
            'confidence': 0.0,
            'status': 'warning',
            'is_melanoma': False,
            'is_unclear': True,
            'top3_classes': []
        }

        try:
            # ── GUARD 1: Face Detection ──
            if self._has_face(image_path):
                INVALID_RESPONSE['message'] = 'A face was detected. This tool is designed for close-up skin lesion photos only, not selfies or portraits.'
                return INVALID_RESPONSE

            # ── GUARD 2: Skin Tone Presence ──
            if not self._has_skin_tones(image_path):
                INVALID_RESPONSE['message'] = 'No skin tones detected in this image. Please upload a close-up photo of a skin lesion or mole on actual skin.'
                return INVALID_RESPONSE

            # ── Preprocess Image ──
            image = Image.open(image_path).convert("RGB")
            width, height = image.size
            new_size = min(width, height)
            left = (width - new_size) / 2
            top = (height - new_size) / 2
            right = (width + new_size) / 2
            bottom = (height + new_size) / 2
            image = image.crop((left, top, right, bottom))
            image = image.resize((224, 224), Image.LANCZOS)

            # ── Run Binary Model ──
            binary_conf = 0.0
            binary_label = "benign"
            if "binary" in self.pipelines:
                preds = self.pipelines["binary"](image)
                if preds:
                    binary_conf = float(preds[0]['score'])
                    binary_label = preds[0]['label'].lower()

            # ── Run Multi-Class Model (ALL 7 classes) ──
            all_preds = []
            if "multi" in self.pipelines:
                all_preds = self.pipelines["multi"](image, top_k=7)  # Get ALL classes

            if not all_preds:
                return {'prediction': 'Engine Error', 'status': 'error'}

            # ── GUARD 3: Combined Validation ──
            if not self._is_valid_lesion(all_preds, binary_conf):
                INVALID_RESPONSE['confidence'] = round(float(all_preds[0]['score']) * 100, 2)
                return INVALID_RESPONSE

            # ── Authentic Results ──
            top_label = all_preds[0]['label'].lower()
            top_conf = float(all_preds[0]['score'])
            final_is_melanoma = "melanoma" in top_label

            # Authentic Top 3 Classes (raw model output)
            top3_classes = []
            for p in all_preds[:3]:
                label = str(p['label']).title()
                conf = round(float(p['score']) * 100, 2)
                top3_classes.append({"label": label, "confidence": conf})

            # Final Result
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
                'confidence': float(round(top_conf * 100, 2)),
                'status': 'success',
                'status_color': status_color,
                'is_melanoma': final_is_melanoma,
                'is_unclear': False,
                'top3_classes': top3_classes,
                'raw_class': all_preds[0]['label'].title()
            }

        except Exception as e:
            traceback.print_exc()
            return {'error': str(e), 'status': 'error', 'prediction': 'Error'}