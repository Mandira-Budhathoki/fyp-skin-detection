from flask import Blueprint, request, jsonify
from appointment_models import Dermatologist, Appointment

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

# --- Routes ---

@appointment_bp.route('/doctors', methods=['GET'])
def get_doctors():
    doctors = Dermatologist.objects.all()
    # No more auto-seeding to avoid confusion
    return jsonify([d.to_dict() for d in doctors]), 200

@appointment_bp.route('/doctors/<string:doctor_id>/slots', methods=['GET'])
def get_booked_slots(doctor_id):
    date_str = request.args.get('date')
    if not date_str:
        return jsonify({'error': 'Date is required'}), 400
    
    try:
        from datetime import datetime
        dt = datetime.strptime(date_str, "%Y-%m-%d")
        day_name = dt.strftime("%A") # e.g., "Monday"
        
        doctor = Dermatologist.objects(id=doctor_id).first()
        if not doctor:
            return jsonify({'error': 'Doctor not found'}), 404
            
        # Get total possible slots for this doctor on this day
        total_slots = []
        for avail in getattr(doctor, 'availability', []):
            if avail.get('day') == day_name:
                total_slots = avail.get('timeSlots', [])
                break
        
        # Get already booked slots for this doctor on this date
        appointments = Appointment.objects(dermatologistId=doctor_id, date=date_str, status__in=['pending', 'approved'])
        booked_slots = [appt.time for appt in appointments]
        
        # Calculate available (free) slots
        # We preserve order of total_slots
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
        
        return jsonify({'success': True, 'message': 'Appointment booked successfully', 'appointment': new_appt.to_dict()}), 201
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
        new_status = data.get('status')
        if new_status not in ['approved', 'rejected']:
            return jsonify({'success': False, 'message': 'Invalid status'}), 400
            
        appt = Appointment.objects(id=appointment_id).first()
        if not appt:
            return jsonify({'success': False, 'message': 'Appointment not found'}), 404
            
        appt.status = new_status
        if 'adminNote' in data:
            appt.adminNote = data['adminNote']
        appt.save()
        
        return jsonify({'success': True, 'message': f'Appointment {new_status} successfully'}), 200
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
