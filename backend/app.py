from flask import Blueprint, request, jsonify, send_from_directory
import os
import cv2
import time
from werkzeug.utils import secure_filename
# from flask_jwt_extended import jwt_optional, get_jwt_identity # REMOVED
import jwt

# Analysis imports
from melanoma_analyzer import MelanomaAnalyzer
from acne_analyzer import AcneAnalyzer
from appointment_models import ScanHistory

# Create Blueprint
image_bp = Blueprint('image_bp', __name__)

# Folders
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
PROCESSED_FOLDER = os.path.join(BASE_DIR, 'processed')

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

# Initialize separate analyzers
melanoma_analyzer = MelanomaAnalyzer()
acne_analyzer = AcneAnalyzer()

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg', 'bmp'}

def get_user_id(req):
    auth_header = req.headers.get('Authorization')
    if auth_header and auth_header.startswith('Bearer '):
        token = auth_header.split(' ')[1]
        try:
            JWT_SECRET = os.getenv('JWT_SECRET', 'supersecretkey123')
            decoded = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
            return decoded.get('id')
        except: return None
    return None

@image_bp.route('/analyze', methods=['POST'])
def analyze_melanoma():
    """Endpoint for Melanoma Analysis"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid image'}), 400

    user_id = get_user_id(request)
    filename = secure_filename(f"melanoma_{int(time.time())}.jpg")
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(file_path)

    try:
        result = melanoma_analyzer.analyze(file_path)
        
        # Save processed image if success
        if result.get('status') == 'success' and 'preprocessed_img' in result:
            processed_path = os.path.join(PROCESSED_FOLDER, filename)
            cv2.imwrite(processed_path, result.pop('preprocessed_img'))
            result['processed_url'] = f"/api/processed/{filename}"

        result['image_url'] = f"/api/uploads/{filename}"

        if result.get('status') == 'success' and user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=result['prediction'],
                confidence=result['confidence'],
                imagePath=filename
            )
            scan.save()

        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Melanoma route failed: {e}")
        return jsonify({'error': str(e)}), 500

@image_bp.route('/analyze/acne', methods=['POST'])
def analyze_acne():
    """Endpoint for General Skin Analysis (Acne, Eczema, etc.)"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid image'}), 400

    user_id = get_user_id(request)
    filename = secure_filename(f"skin_{int(time.time())}.jpg")
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(file_path)

    try:
        result = acne_analyzer.analyze(file_path)
        
        # 1. Save XAI Heatmap
        heatmap_img = result.pop('heatmap_img', None)
        if heatmap_img is not None:
            heatmap_filename = f"heatmap_{filename}"
            heatmap_path = os.path.join(PROCESSED_FOLDER, heatmap_filename)
            cv2.imwrite(heatmap_path, heatmap_img)
            result['processed_url'] = f"/api/processed/{heatmap_filename}"
        
        # 2. Save Preprocessed Image (Quality Check)
        prep_img = result.pop('preprocessed_img', None)
        if prep_img is not None:
            prep_filename = f"prep_{filename}"
            prep_path = os.path.join(PROCESSED_FOLDER, prep_filename)
            cv2.imwrite(prep_path, prep_img)
            result['preprocessed_url'] = f"/api/processed/{prep_filename}"

        result['image_url'] = f"/api/uploads/{filename}"

        if result.get('status') == 'success' and user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=result['prediction'],
                confidence=result['confidence'],
                imagePath=filename
            )
            scan.save()

        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Skin route failed: {e}")
        return jsonify({'error': str(e)}), 500

@image_bp.route('/history', methods=['GET'])
def get_history():
    user_id = get_user_id(request)
    if not user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    scans = ScanHistory.objects(userId=user_id).order_by('-timestamp')
    return jsonify({'history': [s.to_dict() for s in scans]}), 200

@image_bp.route('/uploads/<path:filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@image_bp.route('/processed/<path:filename>')
def processed_file(filename):
    return send_from_directory(PROCESSED_FOLDER, filename)
