import os
import numpy as np
import cv2
import tensorflow as tf
from tensorflow import keras

class AcneAnalyzer:
    def __init__(self):
        self.model = None
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.model_path = os.path.join(self.base_dir, 'ai_models', 'skin_model.keras')
        
        self.class_labels = [
            "Acne (Pimples/Breakout)",
            "Carcinoma (Skin Cancer)",
            "Eczema (Itchy/Inflamed Skin)",
            "Keratosis (Rough/Scaly Patches)",
            "Milia (Small White Bumps)",
            "Rosacea (Chronic Facial Redness)"
        ]
        self.class_keys = ["acne", "carcinoma", "eczema", "keratosis", "milia", "rosacea"]
        self.load_model()

    def load_model(self):
        try:
            if os.path.exists(self.model_path):
                # Using a very safe loading strategy
                self.model = keras.models.load_model(self.model_path, compile=False)
                print(f"[SUCCESS] Skin Condition Model loaded from {self.model_path}")
                # Print model summary to verify it's not a dummy
                # self.model.summary()
            else:
                print(f"[ERROR] Skin Model file NOT found at {self.model_path}")
        except Exception as e:
            print(f"[CRITICAL ERROR] Failed to load skin model: {e}")

    def get_gradcam_heatmap(self, img_array, last_conv_layer_name, pred_index=None):
        try:
            grad_model = tf.keras.models.Model(
                [self.model.inputs], [self.model.get_layer(last_conv_layer_name).output, self.model.output]
            )

            with tf.GradientTape() as tape:
                last_conv_layer_output, preds = grad_model(img_array)
                if pred_index is None:
                    pred_index = tf.argmax(preds[0])
                class_channel = preds[:, pred_index]

            grads = tape.gradient(class_channel, last_conv_layer_output)
            pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))

            last_conv_layer_output = last_conv_layer_output[0]
            heatmap = last_conv_layer_output @ pooled_grads[..., tf.newaxis]
            heatmap = tf.squeeze(heatmap)

            heatmap = tf.maximum(heatmap, 0) / (tf.math.reduce_max(heatmap) + 1e-10)
            return heatmap.numpy()
        except Exception as e:
            print(f"Grad-CAM Error: {e}")
            return None

    def generate_recommendations(self, preds):
        """Generates clinical advice based on multi-class skin predictions."""
        recommendations = []
        target_idx = int(np.argmax(preds))
        conf = float(preds[target_idx] * 100)
        
        # 1. Main Condition Advice
        if target_idx == 0: # Acne
            rec = {"title": "Acne Care", "type": "treatment", "icon": "medical"}
            if conf >= 70:
                rec["description"] = "Moderate to Severe Acne patterns detected. Avoid inflammatory foods and dairy. Consider clinical treatments like Salicylic Acid or Benzoyl Peroxide."
            else:
                rec["description"] = "Mild Acne found. Maintain a gentle cleansing routine and avoid picking at spots to prevent scarring."
            recommendations.append(rec)
        
        elif target_idx == 1: # Carcinoma
            recommendations.append({
                "title": "Medical Alert",
                "type": "urgent",
                "icon": "warning",
                "description": "Visual patterns similar to Carcinoma detected. This requires immediate clinical screening by a dermatologist for a biopsy. Please book an appointment."
            })
            
        elif target_idx == 2: # Eczema
            recommendations.append({
                "title": "Barrier Repair",
                "type": "health",
                "icon": "sunny",
                "description": "Skin appears inflamed/itchy (Eczema). Use thick, fragrance-free ceramides and avoid hot showers which strip natural oils."
            })
            
        elif target_idx == 5: # Rosacea
            recommendations.append({
                "title": "Redness Control",
                "type": "health",
                "icon": "fire",
                "description": "Signs of Rosacea detected. Identify your triggers (spicy food, sun, stress). Use soothing agents like Azelaic Acid or Niacinamide."
            })

        # 2. General Advice
        recommendations.append({
            "title": "Sun Protection",
            "type": "prevention",
            "icon": "sunny",
            "description": "No matter the condition, daily SPF 30+ is the #1 tool for skin health and preventing hyperpigmentation."
        })

        return recommendations

    def analyze(self, image_path):
        if self.model is None:
            return {'prediction': 'Model missing', 'confidence': 0.0, 'status': 'warning'}

        try:
            # 1. READ IMAGE
            img = cv2.imread(image_path)
            if img is None:
                return {'error': 'Could not read image'}
            
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            
            # --- LETTERBOX RESIZING (Avoid Squishing Face) ---
            h, w = img_rgb.shape[:2]
            size = 224
            scale = size / max(h, w)
            nh, nw = int(h * scale), int(w * scale)
            img_scaled = cv2.resize(img_rgb, (nw, nh))
            
            # Create black canvas 224x224
            img_resized = np.zeros((size, size, 3), dtype=np.uint8)
            # Paste scaled image in center
            top = (size - nh) // 2
            left = (size - nw) // 2
            img_resized[top:top+nh, left:left+nw] = img_scaled
            # --------------------------------------------------
            
            # 2. TEST THREE PREPROCESSING SCHEMES (Safety fallback)
            # EfficientNetV2 can sometimes take [0, 1] or raw [0, 255]
            img_raw = img_resized.astype('float32') # [0 - 255]
            img_norm = img_raw / 255.0             # [0 - 1]
            img_prep = tf.keras.applications.efficientnet_v2.preprocess_input(img_raw.copy())
            
            # Predict using the primary strategy (prep/raw)
            # Most modern models from HuggingFace include the rescaling layer inside.
            # If so, passing [0, 1] will make it [0, 0.003], which results in "static" low predictions.
            # Let's try RAW [0-255] first as it's the standard for V2 with internal rescaling.
            preds = self.model.predict(np.expand_dims(img_raw, axis=0), verbose=0)[0]
            
            # --- 🌟 STRICT Invalid/Random Image Handling (Noise Filter) ---
            # If the best guess is less than 10% sure, it's likely a random object or a blurry photo
            target_idx = int(np.argmax(preds))
            top_conf = float(preds[target_idx])
            
            if top_conf < 0.10:
                return {
                    'prediction': 'Unclear Image / Try Again',
                    'message': 'We could not detect a valid skin condition in this photo. Please ensure the skin is centered, focused, and well-lit.',
                    'confidence': float(round(top_conf * 100, 2)),
                    'status': 'warning'
                }

            # 3. ACNE-FIRST ANALYSIS
            # Class index 0 = Acne. Always report acne status first.
            acne_conf = float(round(preds[0] * 100, 2))
            
            # Classify acne severity
            if acne_conf >= 50:
                acne_status = "Moderate Acne"
            elif acne_conf >= 20:
                acne_status = "Mild Acne"
            else:
                acne_status = "No Acne"
            
            # Check other 5 conditions — only report if confidence >= 30%
            other_conditions = []
            for i in range(1, len(self.class_labels)):
                conf = float(round(preds[i] * 100, 2))
                if conf >= 30:
                    other_conditions.append({
                        "label": self.class_labels[i],
                        "key": self.class_keys[i],
                        "confidence": conf
                    })
            # Sort by confidence
            other_conditions.sort(key=lambda x: x['confidence'], reverse=True)

            print(f"[DEBUG] Acne: {acne_conf}% ({acne_status}), Others: {other_conditions}")

            # 4. Grad-CAM Explainable AI
            last_conv_layer = None
            for layer in reversed(self.model.layers):
                try:
                    if 'conv' in layer.name.lower() and len(layer.output.shape) == 4:
                        last_conv_layer = layer.name
                        break
                except: continue
            
            heatmap_img = None
            if last_conv_layer:
                top_idx = int(np.argmax(preds))
                heatmap = self.get_gradcam_heatmap(np.expand_dims(img_raw, axis=0), last_conv_layer, pred_index=top_idx)
                if heatmap is not None:
                    heatmap = np.uint8(255 * heatmap)
                    jet = cv2.applyColorMap(heatmap, cv2.COLORMAP_JET)
                    jet = cv2.resize(jet, (img.shape[1], img.shape[0]))
                    superimposed_img = jet * 0.4 + img * 0.6
                    heatmap_img = superimposed_img.astype('uint8')

            # 5. Build Result
            res_data = {
                'prediction': acne_status,
                'acne_confidence': acne_conf,
                'acne_status': acne_status,
                'confidence': acne_conf,
                'other_conditions': other_conditions,
                'recommendations': self.generate_recommendations(preds),
                'message': f"Acne Level: {acne_status} ({acne_conf}%)",
                'status': 'success',
                'heatmap_img': heatmap_img,
                'preprocessed_img': cv2.cvtColor(img_resized, cv2.COLOR_RGB2BGR)
            }
                
            return res_data

        except Exception as e:
            print(f"[FAIL] Skin analysis: {e}")
            return {'error': str(e), 'status': 'error'}
