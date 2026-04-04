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
from face_health_analyzer import FaceHealthAnalyzer
from wound_analyzer import wound_engine
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
face_health_analyzer = FaceHealthAnalyzer()

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
@image_bp.route('/analyze/melanoma', methods=['POST'])
def analyze_melanoma():
    """Endpoint for Melanoma Analysis (ISIC Ensemble: Binary + Multi-Class)"""
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

        result['image_url'] = f"/api/uploads/{filename}"

        if result.get('status') == 'success' and user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=result.get('prediction', 'Unknown'),
                confidence=result.get('confidence', 0.0),
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

@image_bp.route('/analyze/face-health', methods=['POST'])
def analyze_face_health():
    """Endpoint for Comprehensive Face Health Ensemble Analysis"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid image'}), 400

    user_id = get_user_id(request)
    filename = secure_filename(f"face_health_{int(time.time())}.jpg")
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(file_path)

    try:
        # Run the full ensemble analysis
        result = face_health_analyzer.analyze(file_path)
        
        # If the analyzer completely fails (e.g. invalid file format)
        if result.get('status') == 'fail':
            return jsonify({'error': result.get('error', 'Analysis failed')}), 400

        # Add basic file URLs
        result['image_url'] = f"/api/uploads/{filename}"
        
        # Build a premium summary message
        acne_label = result['acne']['label']
        skin_label = result['skin_type']['label']
        shape_label = result['face_shape']['label']
        
        msg = "Analysis Complete! "
        # Skip labels that represent status/errors
        EXCLUDE = ["Analyzing...", "Inconclusive", "Engine Offline", "Not Loaded"]
        
        if acne_label not in EXCLUDE:
            msg += f"Condition: {acne_label}. "
        if skin_label not in EXCLUDE:
            msg += f"Skin seems {skin_label}. "
        if shape_label not in EXCLUDE:
            msg += f"Face shape: {shape_label}."
            
        result['message'] = msg

        # Log to Scan History if user is authenticated
        if result.get('status') == 'success' and user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=f"Full Health: {acne_label}",
                confidence=result['acne']['confidence'],
                imagePath=filename
            )
            scan.save()

        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Face Health Ensemble failed: {e}")
        return jsonify({'error': str(e)}), 500

@image_bp.route('/analyze/face-health-stream', methods=['POST'])
def analyze_face_health_stream():
    """Streaming endpoint for Face Health Ensemble Analysis"""
    from flask import Response
    import json
    
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400
    
    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid image'}), 400

    user_id = get_user_id(request)
    filename = secure_filename(f"face_health_{int(time.time())}.jpg")
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(file_path)

    def generate():
        try:
            for update in face_health_analyzer.analyze_stream(file_path):
                # If we received the final result, enrich it
                if "result" in update:
                    result = update["result"]
                    result['image_url'] = f"/api/uploads/{filename}"
                    
                    acne_label = result['acne']['label']
                    skin_label = result['skin_type']['label']
                    shape_label = result['face_shape']['label']
                    
                    msg = "Analysis Complete! "
                    EXCLUDE = ["Analyzing...", "Inconclusive", "Engine Offline", "Not Loaded", "Class 2"]
                    if acne_label not in EXCLUDE: msg += f"Condition: {acne_label}. "
                    if skin_label not in EXCLUDE: msg += f"Skin seems {skin_label}. "
                    if shape_label not in EXCLUDE: msg += f"Face shape: {shape_label}."
                    result['message'] = msg

                    if result.get('status') == 'success' and user_id:
                        scan = ScanHistory(
                            userId=user_id,
                            prediction=f"Full Health: {acne_label}",
                            confidence=result['acne']['confidence'],
                            imagePath=filename
                        )
                        scan.save()
                    
                    yield json.dumps(update) + "\n"
                else:
                    yield json.dumps(update) + "\n"
        except Exception as e:
            print(f"[ERROR] Stream failed: {e}")
            yield json.dumps({"error": str(e), "status": "fail"}) + "\n"

    return Response(generate(), mimetype='application/x-ndjson')

@image_bp.route('/analyze/wound', methods=['POST'])
def analyze_wound():
    """Endpoint for Wound Analysis using the Ensemble Engine"""
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    file = request.files['image']
    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid image'}), 400

    user_id = get_user_id(request)
    filename = secure_filename(f"wound_{int(time.time())}.jpg")
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(file_path)

    try:
        image_bytes = open(file_path, 'rb').read()
        raw = wound_engine.analyze(image_bytes)

        # --- Build a clean, frontend-friendly response ---
        primary   = raw.get('primary')
        secondary = raw.get('secondary')
        engine_status = raw.get('engine_status', 'Online')

        # Determine the best prediction using Weighted Consensus
        # If models agree, we are MUCH more confident
        prediction = "Unclear Image / Not a Wound"
        confidence = 0.0
        agreement = "Single Engine"

        p_label = primary['label'] if primary else ""
        p_score = primary['score'] if primary else 0.0
        s_label = secondary['label'] if secondary else ""
        s_score = secondary['score'] if secondary else 0.0

        # Smart Consensus: If they agree, boost confidence and ignore the 40% floor
        if p_label == s_label and p_label != "Unclear Image / Not a Wound":
            prediction = p_label
            confidence = max(p_score, s_score) + 10.0 # Agreement Bonus
            if confidence > 100: confidence = 99.9
            agreement = "Models Agree ✓ (High Confidence)"
        elif p_score >= 40:
            prediction = p_label
            confidence = p_score
            agreement = "Primary Analysis"
        elif s_score >= 50: # Strong specialist opinion
            prediction = s_label
            confidence = s_score
            agreement = "Specialist Opinion"

        # Build user-friendly message
        if "Unclear Image" in prediction:
            msg = "We could not detect a clear wound. Please upload a focused, well-lit image."
            agreement = "Could not verify"
        else:
            msg = f"Wound detected: {prediction} ({confidence:.1f}% confidence). {agreement}."

        result = {
            "status": "success" if engine_status == "Online" else "error",
            "prediction": prediction,
            "confidence": round(confidence, 2),
            "engine_status": engine_status,
            "agreement": agreement,
            "ensemble": {
                "primary":   primary,
                "secondary": secondary,
            },
            "image_url": f"/api/uploads/{filename}",
            "message": msg
        }

        # Save to scan history
        if user_id:
            scan = ScanHistory(
                userId=user_id,
                prediction=f"Wound: {prediction}",
                confidence=confidence,
                imagePath=filename
            )
            scan.save()

        return jsonify(result), 200

    except Exception as e:
        print(f"[ERROR] Wound analysis route failed: {e}")
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
