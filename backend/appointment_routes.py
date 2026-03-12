from flask import Blueprint, request, jsonify
from appointment_models import Dermatologist, Appointment
from datetime import datetime
import os
import jwt

appointment_bp = Blueprint('appointment_bp', __name__)

# --- Helper for Auth ---
def get_user_id(request):
    auth_header = request.headers.get('Authorization')
    if auth_header and auth_header.startswith('Bearer '):
        token = auth_header.split(' ')[1]
        try:
            # Import here to avoid circular dependency if any
            import jwt
            import os
            JWT_SECRET = os.getenv('JWT_SECRET', 'supersecretkey123')
            decoded = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
            return decoded.get('id')
        except:
            return None
    return None

def parse_appt_time(date_str, time_str):
    """Helper to parse date and time strings into a comparable datetime object"""
    try:
        # Handle ranges like "10:00 AM - 11:00 AM" by taking the start time
        clean_time = time_str.split('-')[0].strip()
        
        # Try primary format: "2026-03-12 10:00 AM"
        try:
            return datetime.strptime(f"{date_str} {clean_time}", "%Y-%m-%d %I:%M %p")
        except:
            # Fallback for 24h format: "2026-03-12 14:00"
            return datetime.strptime(f"{date_str} {clean_time}", "%Y-%m-%d %H:%M")
    except:
        return None

# --- Routes ---

@appointment_bp.route('/doctors', methods=['GET'])
def get_doctors():
    # Only show ACTIVE doctors to users
    doctors = Dermatologist.objects(isActive=True)
    return jsonify([d.to_dict() for d in doctors]), 200

@appointment_bp.route('/admin/doctors/all', methods=['GET'])
def get_all_doctors_admin():
    # Admin needs to see even frozen doctors to reactivate them
    doctors = Dermatologist.objects.all()
    return jsonify([d.to_dict() for d in doctors]), 200


@appointment_bp.route('/doctors/<string:doctor_id>/slots', methods=['GET'])
def get_booked_slots(doctor_id):
    date_str = request.args.get('date')
    if not date_str:
        return jsonify({'error': 'Date is required'}), 400
    
    try:
        dt = datetime.strptime(date_str, "%Y-%m-%d")
        day_name = dt.strftime("%A") # e.g., "Monday"
        
        doctor = Dermatologist.objects(id=doctor_id, isActive=True).first()
        if not doctor:
            return jsonify({'error': 'Doctor not found or inactive'}), 404
            
        # Get total possible slots for this doctor on this day
        total_slots = []
        for avail in getattr(doctor, 'availability', []):
            if avail.get('day') == day_name:
                total_slots = avail.get('timeSlots', [])
                break
        
        # Get already booked slots for this doctor on this date
        appointments = Appointment.objects(dermatologistId=doctor_id, date=date_str, status__in=['pending', 'approved'])
        booked_slots = [appt.time for appt in appointments]
        
        available_slots = [s for s in total_slots if s not in booked_slots]
        
        return jsonify({
            'availableSlots': available_slots, 
            'bookedSlots': booked_slots,
            'totalSlots': total_slots
        }), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@appointment_bp.route('/book', methods=['POST'])
def book_appointment():
    try:
        data = request.get_json()
        user_id = get_user_id(request)
        if not user_id:
            return jsonify({'success': False, 'message': 'Authentication required'}), 401
        
        required = ['dermatologistId', 'date', 'time']
        if not all(k in data for k in required):
            return jsonify({'success': False, 'message': 'Missing fields'}), 400

        # --- Strict Past Date/Time Check ---
        appt_dt = parse_appt_time(data['date'], data['time'])
        if not appt_dt or appt_dt < datetime.now():
            return jsonify({
                'success': False, 
                'message': 'The selected time has already passed. Please pick a future slot.'
            }), 400

        # Check for conflict
        existing = Appointment.objects(
            dermatologistId=data['dermatologistId'],
            date=data['date'],
            time=data['time'],
            status__in=['pending', 'approved']
        ).first()
        
        if existing:
            return jsonify({'success': False, 'message': 'Slot already booked'}), 409

        new_appt = Appointment(
            userId=user_id,
            dermatologistId=data['dermatologistId'],
            date=data['date'],
            time=data['time'],
            notes=data.get('notes', ''),
            patientName=data.get('patientName', ''),
            phoneNumber=data.get('phoneNumber', ''),
            status='pending'
        )
        new_appt.save()
        
        return jsonify({'success': True, 'message': 'Request Submitted! Waiting for Admin finalization.', 'appointment': new_appt.to_dict()}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@appointment_bp.route('/my', methods=['GET'])
def my_appointments():
    user_id = get_user_id(request)
    if not user_id:
        return jsonify([]), 200
    appointments = Appointment.objects(userId=user_id).order_by('-date', '-time')
    
    return jsonify({'appointments': [a.to_dict() for a in appointments]}), 200

@appointment_bp.route('/<string:appointment_id>', methods=['DELETE'])
def cancel_appointment(appointment_id):
    try:
        appt = Appointment.objects(id=appointment_id).first()
        if not appt:
            return jsonify({'success': False, 'message': 'Appointment not found'}), 404
            
        appt.status = 'cancelled'
        appt.save()
        
        return jsonify({'success': True, 'message': 'Appointment cancelled'}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@appointment_bp.route('/admin/users', methods=['GET'])
def get_all_users():
    # Only Admin should see this in a real app
    from appointment_models import User
    users = User.objects().order_by('name')
    return jsonify({'success': True, 'users': [u.to_dict() for u in users]}), 200

# --- Admin Routes ---

@appointment_bp.route('/admin/pending', methods=['GET'])
def get_pending_appointments():
    # In a real app, verify admin role from token here
    appointments = Appointment.objects(status='pending').order_by('-date', '-time')
    return jsonify({'appointments': [a.to_dict() for a in appointments]}), 200

@appointment_bp.route('/admin/all', methods=['GET'])
def get_all_appointments():
    # Fetch all appointments for history view
    appointments = Appointment.objects().order_by('-date', '-time')
    return jsonify({'appointments': [a.to_dict() for a in appointments]}), 200

@appointment_bp.route('/admin/status/<string:appointment_id>', methods=['PUT'])
def update_appointment_status(appointment_id):
    try:
        data = request.get_json()
        new_status = data.get('status', '').lower()
        if new_status not in ['approved', 'rejected', 'cancelled']:
            return jsonify({'success': False, 'message': 'Invalid status. Must be approved, rejected or cancelled'}), 400
            
        appt = Appointment.objects(id=appointment_id).first()
        if not appt:
            return jsonify({'success': False, 'message': 'Appointment not found'}), 404
            
        # Real-time check for approval
        if new_status == 'approved':
            appt_dt = parse_appt_time(appt.date, appt.time)
            if appt_dt and appt_dt < datetime.now():
                return jsonify({
                    'success': False, 
                    'message': 'The time has already gone so cannot be accepted.'
                }), 400

        appt.status = new_status
        if 'adminNote' in data:
            appt.adminNote = data['adminNote']
        appt.save()
        
        return jsonify({'success': True, 'message': f'Appointment {new_status} successfully'}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@appointment_bp.route('/admin/doctors', methods=['POST'])
def add_doctor():
    try:
        data = request.get_json()
        if not data or 'name' not in data or 'specialization' not in data:
            return jsonify({'success': False, 'message': 'Name and Specialization are required'}), 400
            
        new_doc = Dermatologist(
            name=data['name'],
            specialization=data['specialization'],
            qualification=data.get('qualification', 'MBBS, MD'),
            experience=data.get('experience', 0),
            about=data.get('about', ''),
            hourlyRate=data.get('hourlyRate', 1000),
            imageUrl=data.get('imageUrl', 'assets/images/logo.png'),
            rating=5.0,
            reviewsCount=0,
            availability=data.get('availability', [
                { "day": "Monday", "timeSlots": ["10:00", "11:00", "14:00"] },
                { "day": "Wednesday", "timeSlots": ["10:00", "11:00", "14:00"] },
                { "day": "Friday", "timeSlots": ["10:00", "11:00", "14:00"] }
            ])
        )
        new_doc.save()
        return jsonify({'success': True, 'message': 'Doctor added successfully', 'doctor': new_doc.to_dict()}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@appointment_bp.route('/admin/doctors/toggle/<string:doctor_id>', methods=['PUT'])
def toggle_doctor_status(doctor_id):
    try:
        doc = Dermatologist.objects(id=doctor_id).first()
        if not doc:
            return jsonify({'success': False, 'message': 'Doctor not found'}), 404
            
        doc.isActive = not getattr(doc, 'isActive', True)
        doc.save()
        
        status = "Activated" if doc.isActive else "Frozen (Hidden from Users)"
        return jsonify({'success': True, 'message': f'Doctor {status} successfully'}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@appointment_bp.route('/admin/users/toggle/<string:user_id>', methods=['PUT'])
def toggle_user_status(user_id):
    try:
        from appointment_models import User
        user = User.objects(id=user_id).first()
        if not user:
            return jsonify({'success': False, 'message': 'User not found'}), 404
            
        user.isFrozen = not getattr(user, 'isFrozen', False)
        user.save()
        
        status = "Frozen (Login Blocked)" if user.isFrozen else "Unfrozen"
        return jsonify({'success': True, 'message': f'User {status} successfully'}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500


@appointment_bp.route('/seed', methods=['POST'])
def seed_doctors():
    try:
        Dermatologist.objects().delete()

        doctors = [
            {
                "name": "Dr. Rukmila Shrestha",
                "specialization": "Melanoma Specialist",
                "imageUrl": "assets/images/doctor1.jpeg",
                "availability": [
                    { "day": d, "timeSlots": ["08:00 AM - 09:00 AM", "09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM"] } for d in ["Monday", "Wednesday", "Friday", "Sunday"]
                ]
            },
            {
                "name": "Dr. Milan Karki",
                "specialization": "Wound Care Specialist",
                "imageUrl": "assets/images/doctor2.jpg",
                "availability": [
                    { "day": d, "timeSlots": ["09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM", "02:00 PM - 03:00 PM"] } for d in ["Tuesday", "Thursday", "Saturday", "Monday"]
                ]
            },
            {
                "name": "Dr. David Miller",
                "specialization": "General Skin Health",
                "imageUrl": "assets/images/doctor3.png",
                "availability": [
                    { "day": d, "timeSlots": ["08:00 AM - 09:00 AM", "09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM"] } for d in ["Wednesday", "Friday", "Sunday", "Tuesday"]
                ]
            },
            {
                "name": "Dr. Sama Thapa",
                "specialization": "Pediatric Dermatology",
                "imageUrl": "assets/images/doctor4.jpg",
                "availability": [
                    { "day": d, "timeSlots": ["09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM"] } for d in ["Thursday", "Saturday", "Monday", "Wednesday"]
                ]
            },
            {
                "name": "Dr. Mandira Budhathoki",
                "specialization": "Melanoma & Lesions",
                "imageUrl": "assets/images/doctor7.jpg",
                "availability": [
                    { "day": d, "timeSlots": ["10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM", "02:00 PM - 03:00 PM"] } for d in ["Friday", "Sunday", "Tuesday", "Thursday"]
                ]
            },
            {
                "name": "Dr. Dipendra Rai",
                "specialization": "Cosmetic Surgeon",
                "imageUrl": "assets/images/doctor6.jpg",
                "availability": [
                    { "day": d, "timeSlots": ["09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM"] } for d in ["Saturday", "Monday", "Wednesday", "Friday"]
                ]
            },
            {
                "name": "Dr. Maiya Karki",
                "specialization": "Dermatologist",
                "imageUrl": "assets/images/doctor5.jpg",
                "availability": [
                    { "day": d, "timeSlots": ["08:00 AM - 09:00 AM", "10:00 AM - 11:00 AM", "12:00 PM - 01:00 PM", "02:00 PM - 03:00 PM"] } for d in ["Sunday", "Tuesday", "Thursday", "Saturday"]
                ]
            },
            {
                "name": "Dr. Sandesh Basnet",
                "specialization": "Clinical Dermatologist",
                "imageUrl": "assets/images/doctor8.jpg",
                "availability": [
                    { "day": d, "timeSlots": ["09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM", "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM"] } for d in ["Monday", "Wednesday", "Friday", "Sunday"]
                ]
            }
        ]

        for doc_data in doctors:
            # Using update to avoid lint issues with mixed types in setdefault
            defaults = {
                "qualification": "MD, Dermatology",
                "experience": 10,
                "about": "Expert in skin care and dermatological procedures.",
                "hourlyRate": 2000,
                "rating": 4.8,
                "reviewsCount": 50,
                "isActive": True
            }
            for key, value in defaults.items():
                if key not in doc_data:
                    doc_data[key] = value
            
            Dermatologist(**doc_data).save()

        return jsonify({'success': True, 'message': 'Doctors seeded with full-week availability!'}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

