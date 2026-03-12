from flask import Blueprint, request, jsonify
import os
import cv2
from appointment_models import ScanHistory
from melanoma_analyzer import MelanomaAnalyzer
from acne_analyzer import AcneAnalyzer
import jwt

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
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    try:
        result = melanoma_analyzer.analyze(file_path)
        
        # Save processed image if success
        if result.get('status') == 'success' and 'preprocessed_img' in result:
            processed_path = os.path.join(PROCESSED_FOLDER, file.filename)
            cv2.imwrite(processed_path, result.pop('preprocessed_img'))

        if result.get('status') == 'success' and user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=result['prediction'],
                confidence=result['confidence'],
                imagePath=file.filename
            )
            scan.save()

        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Melanoma route failed: {e}")
        return jsonify({'error': str(e)}), 500

@image_bp.route('/analyze/acne', methods=['POST'])
def analyze_acne():
    """Endpoint for Acne Analysis (Skin Guide)"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid image'}), 400

    user_id = get_user_id(request)
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    try:
        result = acne_analyzer.analyze(file_path)
        
        # Save preprocessed image for user to see (224x224 version)
        if result.get('status') == 'success' and 'processed_img' in result:
            processed_path = os.path.join(PROCESSED_FOLDER, file.filename)
            cv2.imwrite(processed_path, result.pop('processed_img'))

        if result.get('status') == 'success' and user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=result['prediction'],
                confidence=result['confidence'],
                imagePath=file.filename
            )
            scan.save()

        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Acne route failed: {e}")
        return jsonify({'error': str(e)}), 500

@image_bp.route('/history', methods=['GET'])
def get_history():
    user_id = get_user_id(request)
    if not user_id:
        return jsonify({'error': 'Unauthorized'}), 401
    
    scans = ScanHistory.objects(userId=user_id).order_by('-timestamp')
    return jsonify({'history': [s.to_dict() for s in scans]}), 200
