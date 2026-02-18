from flask import Blueprint, request, jsonify
from flask_bcrypt import Bcrypt
import jwt
import os
from appointment_models import User

auth_bp = Blueprint('auth_bp', __name__)
bcrypt = Bcrypt()

# Constants from environment
JWT_SECRET = os.getenv('JWT_SECRET', 'supersecretkey123')
ADMIN_SECRET = os.getenv('ADMIN_SECRET', 'admin123')

@auth_bp.route('/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        role = data.get('role', 'user')

        if not email or not password:
            return jsonify({'success': False, 'message': 'Email and password are required'}), 400

        if User.objects(email=email).first():
            return jsonify({'success': False, 'message': 'User already exists'}), 400

        hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
        new_user = User(name=name, email=email, password=hashed_password, role=role)
        new_user.save()

        return jsonify({'success': True, 'message': 'User registered successfully'}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@auth_bp.route('/register-admin', methods=['POST'])
def register_admin():
    try:
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')
        password = data.get('password')
        admin_secret_input = data.get('adminSecret')

        if admin_secret_input != ADMIN_SECRET:
            return jsonify({'success': False, 'message': 'Invalid Admin Secret Key'}), 403

        admin_count = User.objects(role='admin').count()
        if admin_count >= 3:
            return jsonify({'success': False, 'message': 'Admin limit reached (Maximum 3 admins allowed)'}), 400

        if User.objects(email=email).first():
            return jsonify({'success': False, 'message': 'User already exists'}), 400

        hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
        new_admin = User(name=name, email=email, password=hashed_password, role='admin')
        new_admin.save()

        return jsonify({'success': True, 'message': 'Admin registered successfully'}), 201
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        email = data.get('email', '').strip().lower()
        password = data.get('password', '').strip()

        print(f"Login attempt for: [{email}]")
        user = User.objects(email=email).first()
        
        if not user:
            print(f"User not found for email: [{email}]")
            return jsonify({'success': False, 'message': 'Invalid credentials'}), 401
            
        if not bcrypt.check_password_hash(user.password, password):
            print(f"Password mismatch for user: [{email}]")
            return jsonify({'success': False, 'message': 'Invalid credentials'}), 401

        print(f"Login success for user: [{email}] with role: {user.role}")
        token = jwt.encode({
            'id': str(user.id),
            'email': user.email,
            'role': user.role
        }, JWT_SECRET, algorithm='HS256')

        return jsonify({
            'success': True,
            'message': 'Login successful',
            'token': token,
            'user': {
                'id': str(user.id),
                'name': user.name,
                'email': user.email,
                'role': user.role
            }
        }), 200
    except Exception as e:
        print(f"Login error: {str(e)}")
        return jsonify({'success': False, 'message': str(e)}), 500

@auth_bp.route('/users', methods=['GET'])
def get_all_users():
    # In a real app, verify admin role from token here
    users = User.objects().order_by('name')
    return jsonify({'success': True, 'users': [u.to_dict() for u in users]}), 200
