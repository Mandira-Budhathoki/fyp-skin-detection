import os
import numpy as np
import cv2
import tensorflow as tf
from utils.preprocessing import preprocess_melanoma_image

class MelanomaAnalyzer:
    def __init__(self):
        self.model = None
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.model_path = os.path.join(self.base_dir, 'ai_models', 'mela_model_final.keras')
        self.class_labels = [
            "Actinic keratoses", "Basal cell carcinoma", "Benign keratosis-like lesions",
            "Dermatofibroma", "Melanoma", "Melanocytic nevi", "Vascular lesions"
        ]
        self.load_model()

    def load_model(self):
        try:
            if os.path.exists(self.model_path):
                self.model = tf.keras.models.load_model(self.model_path)
                print(f"[SUCCESS] Melanoma Model loaded from {self.model_path}")
            else:
                print(f"[WARNING] Melanoma Model file NOT found at {self.model_path}")
        except Exception as e:
            print(f"[ERROR] Failed to load melanoma model: {e}")

    def analyze(self, image_path):
        if self.model is None:
            return {'prediction': 'Model missing', 'confidence': 0.0, 'status': 'warning'}

        try:
            preprocessed = preprocess_melanoma_image(image_path)
            if preprocessed is None:
                return {'error': 'Preprocessing failed', 'status': 'error'}

            img_array = preprocessed.astype('float32') / 255.0
            img_array = np.expand_dims(img_array, axis=0)
            
            predictions = self.model.predict(img_array)
            class_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][class_idx])
            
            return {
                'prediction': self.class_labels[class_idx],
                'confidence': float(round(confidence * 100, 2)),
                'status': 'success',
                'preprocessed_img': preprocessed
            }
        except Exception as e:
            print(f"[ERROR] Melanoma analysis failed: {e}")
            return {'error': str(e), 'status': 'error'}
