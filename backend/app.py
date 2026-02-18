from flask import Blueprint, request, jsonify
import os
import numpy as np
import cv2
from utils.preprocessing import preprocess_melanoma_image

# Attempt to import TensorFlow
try:
    import tensorflow as tf
except ImportError:
    tf = None

# Create Blueprint
image_bp = Blueprint('image_bp', __name__)

# Folders
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
PROCESSED_FOLDER = os.path.join(BASE_DIR, 'processed')
# This is where the user should put their .keras file
MODEL_PATH = os.path.join(BASE_DIR, 'ai_models', 'mela_model_final.keras')

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

# Load model globally
model = None
if tf:
    try:
        if os.path.exists(MODEL_PATH):
            model = tf.keras.models.load_model(MODEL_PATH)
            print(f"[SUCCESS] Model loaded from {MODEL_PATH}")
        else:
            print(f"[WARNING] Model file NOT found at {MODEL_PATH}")
            print(f"Please ensure your model is named 'mela_model_final.keras' and placed in {os.path.join(BASE_DIR, 'ai_models')}")
    except Exception as e:
        print(f"[ERROR] Failed to load model: {e}")

# Class Labels (HAM10000 Standard)
CLASS_LABELS = [
    "Actinic keratoses",
    "Basal cell carcinoma",
    "Benign keratosis-like lesions",
    "Dermatofibroma",
    "Melanoma",
    "Melanocytic nevi",
    "Vascular lesions"
]

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'bmp'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@image_bp.route('/analyze', methods=['POST'])
def analyze():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No image selected'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': 'Unsupported file type'}), 400

    # Save original image
    image_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(image_path)
    print(f"[DEBUG] Received and saved file: {file.filename} at {image_path}")

    # Preprocess image
    try:
        preprocessed = preprocess_melanoma_image(image_path)
        if preprocessed is None:
            raise ValueError("Preprocessing returned None")
            
        processed_path = os.path.join(PROCESSED_FOLDER, file.filename)
        cv2.imwrite(processed_path, preprocessed)
        print(f"[DEBUG] Preprocessed image saved at: {processed_path}")

        # Real model prediction logic
        if model:
            # Prepare image for model (Normalize and Batch)
            img_array = preprocessed.astype('float32') / 255.0
            img_array = np.expand_dims(img_array, axis=0)
            
            # Predict
            predictions = model.predict(img_array)
            class_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][class_idx])
            
            result = {
                'prediction': CLASS_LABELS[class_idx],
                'confidence': float(round(confidence * 100, 2)), # e.g. 92.45
                'status': 'success'
            }
        else:
            # Fallback to dummy if model not loaded
            result = {
                'prediction': 'Model File Missing (mela_model_final.keras)',
                'confidence': 0.0,
                'status': 'warning'
            }

        print(f"[DEBUG] Returning result: {result}")
        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Analysis failed: {e}")
        return jsonify({'error': f"Analysis failed: {str(e)}"}), 500
