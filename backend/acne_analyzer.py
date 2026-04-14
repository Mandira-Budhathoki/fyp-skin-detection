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
        """Generates condition-specific clinical advice based on predictions."""
        recommendations = []
        target_idx = int(np.argmax(preds))
        
        if target_idx == 0: # Acne
            recommendations.append({
                "title": "Clinical Causes",
                "type": "health",
                "icon": "sunny",
                "description": "Acne occurs when hair follicles plug with oil and dead skin cells, often triggered by hormonal changes, diet, stress, or certain medications."
            })
            recommendations.append({
                "title": "Acne Treatment",
                "type": "treatment",
                "icon": "medical",
                "description": "Use cleansers containing Salicylic Acid or Benzoyl Peroxide to unclog pores and reduce breakouts. Apply a light, non-comedogenic moisturizer."
            })
            recommendations.append({
                "title": "Precautions",
                "type": "prevention",
                "icon": "warning",
                "description": "Avoid picking or popping pimples, as this can lead to permanent scarring and pigment changes. Regularly clean your phone screen and pillowcases."
            })

        elif target_idx == 1: # Carcinoma
            recommendations.append({
                "title": "What is Carcinoma?",
                "type": "health",
                "icon": "sunny",
                "description": "Carcinoma is a type of skin cancer primarily caused by prolonged, cumulative exposure to ultraviolet (UV) radiation from the sun or tanning beds."
            })
            recommendations.append({
                "title": "Immediate Medical Alert",
                "type": "urgent",
                "icon": "warning",
                "description": "Visual patterns indicate potential Carcinoma (Skin Cancer). This requires an immediate clinical screening and biopsy by a certified dermatologist."
            })
            recommendations.append({
                "title": "Next Clinical Steps",
                "type": "treatment",
                "icon": "medical",
                "description": "Do not attempt to treat this at home. Keep the specific area clean and protected from the sun, and book an urgent doctor consultation."
            })

        elif target_idx == 2: # Eczema
            recommendations.append({
                "title": "Clinical Causes",
                "type": "health",
                "icon": "sunny",
                "description": "Eczema (Atopic Dermatitis) is related to a gene variation that affects the skin's ability to retain moisture and protect against bacteria and allergens."
            })
            recommendations.append({
                "title": "Barrier Repair",
                "type": "treatment",
                "icon": "medical",
                "description": "Apply thick, fragrance-free ceramide creams immediately after showering (while skin is damp) to lock in moisture and repair the skin barrier."
            })
            recommendations.append({
                "title": "Avoid Triggers",
                "type": "prevention",
                "icon": "warning",
                "description": "Avoid extremely hot water, harsh alkaline soaps, and scratchy fabrics like wool. Manage stress, which can heavily trigger eczema flare-ups."
            })

        elif target_idx == 3: # Keratosis
            recommendations.append({
                "title": "Clinical Causes",
                "type": "health",
                "icon": "sunny",
                "description": "Keratosis Pilaris (strawberry skin) is caused by the buildup of keratin—a hard protein that protects skin from harmful substances and infection."
            })
            recommendations.append({
                "title": "Chemical Exfoliation",
                "type": "treatment",
                "icon": "medical",
                "description": "Use lotions containing Alpha Hydroxy Acids (AHAs), Lactic Acid, or Urea to gently dissolve the rough, scaly keratin plugs."
            })
            recommendations.append({
                "title": "Hydration Practices",
                "type": "prevention",
                "icon": "warning",
                "description": "Keep the skin consistently moisturized. Avoid aggressive physical loofahs or harsh scrubs, which can irritate the skin and worsen redness."
            })

        elif target_idx == 4: # Milia
            recommendations.append({
                "title": "Clinical Causes",
                "type": "health",
                "icon": "sunny",
                "description": "Milia are small cysts formed when dead skin flakes (keratin) become trapped under the surface of the skin, often caused by heavy skincare products."
            })
            recommendations.append({
                "title": "Cellular Turnover",
                "type": "treatment",
                "icon": "medical",
                "description": "Incorporate a gentle chemical exfoliant like Glycolic Acid (AHA) or Retinol to increase cell turnover and dissolve trapped keratin naturally."
            })
            recommendations.append({
                "title": "Product Re-evaluation",
                "type": "prevention",
                "icon": "warning",
                "description": "Stop using heavy, pore-clogging eye creams or thick occlusive moisturizers. Never attempt to poke or squeeze Milia at home to avoid scarring and infection."
            })

        elif target_idx == 5: # Rosacea
            recommendations.append({
                "title": "Clinical Causes",
                "type": "health",
                "icon": "sunny",
                "description": "Rosacea is a chronic inflammatory skin condition. While the exact cause is unknown, it involves a combination of hereditary and environmental factors."
            })
            recommendations.append({
                "title": "Redness & Inflammation",
                "type": "treatment",
                "icon": "medical",
                "description": "Apply soothing, anti-inflammatory ingredients like Azelaic Acid, Niacinamide, or Centella Asiatica to reduce visible redness effectively."
            })
            recommendations.append({
                "title": "Trigger Management",
                "type": "prevention",
                "icon": "fire",
                "description": "Identify and aggressively avoid common daily triggers, including excessive sun exposure, spicy foods, hot beverages, and alcohol."
            })

        return recommendations

    def _has_skin_tones(self, image_path):
        """
        Validates if the uploaded image actually contains skin.
        Prevents the model from 'diagnosing' random objects.
        """
        try:
            img = cv2.imread(image_path)
            if img is None: return False
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

            lower1 = np.array([0,  20, 70], dtype=np.uint8)
            upper1 = np.array([20, 255, 255], dtype=np.uint8)
            lower2 = np.array([170, 20, 70], dtype=np.uint8)
            upper2 = np.array([180, 255, 255], dtype=np.uint8)

            mask1 = cv2.inRange(hsv, lower1, upper1)
            mask2 = cv2.inRange(hsv, lower2, upper2)
            skin_mask = cv2.bitwise_or(mask1, mask2)

            total_pixels = img.shape[0] * img.shape[1]
            skin_pixels = int(np.sum(skin_mask > 0))
            skin_ratio = skin_pixels / total_pixels

            return skin_ratio >= 0.15 # Require at least 15% skin pixels
        except:
            return True

    def analyze(self, image_path):
        if self.model is None:
            return {'prediction': 'Model missing', 'confidence': 0.0, 'status': 'warning'}

        try:
            # 1. READ & VALIDATE IMAGE
            if not self._has_skin_tones(image_path):
                return {
                    'prediction': 'Invalid Image',
                    'message': 'No skin tones detected. Please upload a clear photo of actual skin for analysis.',
                    'confidence': 0.0,
                    'status': 'warning',
                    'other_conditions': [],
                    'recommendations': [{
                        'title': 'Scan Rejected',
                        'type': 'urgent',
                        'icon': 'warning',
                        'description': 'The AI engine blocked this scan because it does not appear to be a skin photograph. Please avoid uploading random objects, highly shadowed photos, or non-human subjects.'
                    }]
                }

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
            
            # --- STRICT Invalid/Random Image Handling (Noise Filter) ---
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
            
            # Use the model's direct winner as the primary status
            target_idx = int(np.argmax(preds))
            acne_status = self.class_labels[target_idx]
            acne_conf = float(round(preds[target_idx] * 100, 2))
            
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
