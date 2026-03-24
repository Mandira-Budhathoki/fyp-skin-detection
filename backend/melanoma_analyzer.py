import os
import numpy as np
import cv2
import tensorflow as tf
from utils.preprocessing import preprocess_melanoma_image

class MelanomaAnalyzer:
    def __init__(self):
        self.model = None
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.model_path = os.path.join(self.base_dir, 'ai_models', 'efficientnetv2s.h5')
        self.class_labels = [
            "Actinic Keratoses and Intraepithelial Carcinoma (AKIEC)",
            "Basal Cell Carcinoma (BCC)",
            "Benign Keratosis-like Lesions (BKL)",
            "Dermatofibroma (DF)",
            "Melanoma (MEL)",
            "Melanocytic Nevi (NV)",
            "Vascular Lesions (VASC)"
        ]
        self.load_model()

    def load_model(self):
        try:
            if os.path.exists(self.model_path):
                import keras
                from keras.layers import DepthwiseConv2D

                class CustomDepthwiseConv2D(DepthwiseConv2D):
                    def __init__(self, **kwargs):
                        if 'groups' in kwargs:
                            del kwargs['groups']
                        super().__init__(**kwargs)

                with keras.utils.custom_object_scope({'DepthwiseConv2D': CustomDepthwiseConv2D}):
                    self.model = keras.models.load_model(self.model_path)
                    
                print(f"[SUCCESS] Melanoma Model loaded from {self.model_path}")
            else:
                print(f"[WARNING] Melanoma Model file NOT found at {self.model_path}")
        except Exception as e:
            print(f"[ERROR] Failed to load melanoma model: {e}")

    def analyze(self, image_path):
        if self.model is None:
            return {'prediction': 'Model missing', 'confidence': 0.0, 'status': 'warning'}

        try:
            # 1️⃣ Preprocess (Miguel764 logic)
            preprocessed = preprocess_melanoma_image(image_path)
            if preprocessed is None:
                return {'error': 'Preprocessing failed', 'status': 'error'}

            # The Miguel764 model expects [-1, 1] range: (img/255.0 - 0.5) * 2
            img_array = (preprocessed.astype('float32') / 255.0 - 0.5) * 2
            img_array = np.expand_dims(img_array, axis=0)
            
            # 2️⃣ Predict Logits & apply Temperature Scaling (T=2.77)
            TEMPERATURE = 2.77
            
            # Extract features (the input to the final Dense layer)
            # We take the output of the second-to-last layer
            feature_model = tf.keras.Model(inputs=self.model.input, outputs=self.model.layers[-2].output)
            features = feature_model.predict(img_array, verbose=0)[0]
            
            # Get weights and biases from the final Dense layer to manually calculate logits
            final_layer = self.model.layers[-1]
            weights, biases = final_layer.get_weights()
            
            # Manual logit calculation: Logits = (Features * Weights) + Bias
            raw_logits = np.dot(features, weights) + biases
            
            # Apply T-Scaling to reduce overconfidence (Miguel764 calibration)
            scaled_logits = raw_logits / TEMPERATURE
            
            # Re-calculate Softmax manually
            exp_logits = np.exp(scaled_logits - np.max(scaled_logits))
            scaled_probs = exp_logits / exp_logits.sum()
            
            # 3️⃣ Top class & binary mapping
            class_idx = int(np.argmax(scaled_probs))
            confidence = float(scaled_probs[class_idx])
            raw_class_name = self.class_labels[class_idx]

            # Binary result: Melanoma or Non-Melanoma
            is_melanoma = (class_idx == 4)
            binary_result = "Melanoma Detected" if is_melanoma else "Non-Melanoma (Safe)"
            melanoma_prob = float(scaled_probs[4])  # MEL index

            # 4️⃣ Top 3 classes
            top_indices = np.argsort(scaled_probs)[::-1][:3]
            top3_classes = [
                {"label": self.class_labels[i], "confidence": float(round(scaled_probs[i]*100, 2))}
                for i in top_indices
            ]

            # 5️⃣ Handle very unclear / random images gracefully
            # If top class confidence very low (<20%), consider image unclear
            if confidence < 0.2:
                return {
                    'prediction': 'Unclear Image / Not a Skin Lesion',
                    'message': 'We could not confidently detect a clear skin lesion. Please upload a focused, well-lit dermatoscopic image.',
                    'confidence': float(round(confidence*100, 2)),
                    'status': 'warning',
                    'top3_classes': top3_classes,
                    'preprocessed_img': cv2.cvtColor(preprocessed, cv2.COLOR_RGB2BGR)
                }

            # 6️⃣ Construct user-friendly message
            if is_melanoma:
                message = 'Warning: The analysis indicates signs of Melanoma. Please consult a dermatologist immediately for a professional medical diagnosis.'
                status_color = 'danger'
            else:
                message = f'The lesion appears to be benign ({raw_class_name}). Monitor your skin and consult a doctor if unsure.'
                status_color = 'success'

            # 7️⃣ JSON-ready output for Flutter
            return {
                'prediction': binary_result,
                'message': message,
                'confidence': float(round(confidence*100, 2)),
                'status': 'success',
                'status_color': status_color,
                'is_melanoma': is_melanoma,
                'raw_class': raw_class_name,
                'melanoma_prob': float(round(melanoma_prob*100, 2)),
                'top3_classes': top3_classes,
                'all_classes': [
                    {"label": self.class_labels[i], "confidence": float(round(scaled_probs[i]*100, 2))}
                    for i in range(len(scaled_probs))
                ],
                'preprocessed_img': cv2.cvtColor(preprocessed, cv2.COLOR_RGB2BGR)
            }

        except Exception as e:
            print(f"[ERROR] Melanoma analysis failed: {e}")
            return {'error': str(e), 'status': 'error'}