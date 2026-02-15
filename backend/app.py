from flask import Blueprint, request, jsonify
import os
from utils.preprocessing import preprocess_melanoma_image
import cv2

# Create Blueprint
image_bp = Blueprint('image_bp', __name__)

# Folders
UPLOAD_FOLDER = 'uploads'
PROCESSED_FOLDER = 'processed'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

# Allowed extensions for safety
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'bmp'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Route using Blueprint now
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
            raise ValueError("Preprocessing returned None (invalid image format?)")
        processed_path = os.path.join(PROCESSED_FOLDER, file.filename)
        cv2.imwrite(processed_path, preprocessed)
        print(f"[DEBUG] Preprocessed image saved at: {processed_path}")
    except Exception as e:
        print(f"[ERROR] Preprocessing failed: {e}")
        return jsonify({'error': f"Preprocessing failed: {str(e)}"}), 500

    # Dummy model prediction
    dummy_result = {
        'prediction': 'benign',
        'confidence': 0.85
    }

    print(f"[DEBUG] Returning result: {dummy_result}")
    return jsonify(dummy_result), 200
