import mongoengine
from bson import ObjectId
from datetime import datetime

def clean_data(data):
    if isinstance(data, list):
        return [clean_data(item) for item in data]
    if isinstance(data, dict):
        return {k: clean_data(v) for k, v in data.items()}
    if isinstance(data, ObjectId):
        return str(data)
    if isinstance(data, datetime):
        return data.isoformat()
    return data

class User(mongoengine.DynamicDocument):
    name = mongoengine.StringField()
    email = mongoengine.StringField(unique=True, required=True)
    password = mongoengine.StringField(required=True)
    role = mongoengine.StringField(default='user')
    
    meta = {'collection': 'users', 'strict': False}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            '_id': str(self.id),
            'name': getattr(self, 'name', ''),
            'email': getattr(self, 'email', ''),
            'role': getattr(self, 'role', 'user')
        })

class Dermatologist(mongoengine.DynamicDocument):
    name = mongoengine.StringField(required=True)
    specialization = mongoengine.StringField(required=True)
    
    meta = {'collection': 'dermatologists', 'strict': False}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            '_id': str(self.id),
            'name': getattr(self, 'name', ''),
            'specialization': getattr(self, 'specialization', ''),
            'imageUrl': getattr(self, 'imageUrl', "https://via.placeholder.com/150"),
            'qualification': getattr(self, 'qualification', ''),
            'experience': getattr(self, 'experience', 0),
            'about': getattr(self, 'about', ''),
            'rating': getattr(self, 'rating', 5.0),
            'reviewsCount': getattr(self, 'reviewsCount', 0),
            'hourlyRate': getattr(self, 'hourlyRate', 0),
            'availability': getattr(self, 'availability', [])
        })

class Appointment(mongoengine.DynamicDocument):
    userId = mongoengine.ReferenceField(User, required=True)
    dermatologistId = mongoengine.ReferenceField(Dermatologist, required=True)
    date = mongoengine.StringField(required=True)
    time = mongoengine.StringField(required=True)
    status = mongoengine.StringField(default='pending')
    adminNote = mongoengine.StringField()
    patientName = mongoengine.StringField()
    phoneNumber = mongoengine.StringField()
    
    meta = {'collection': 'appointments', 'strict': False}

    def to_dict(self):
        # Safely get the doctor data
        doctor_data = None
        try:
            if self.dermatologistId:
                doctor_data = self.dermatologistId.to_dict()
        except:
            doctor_data = {"name": "Deleted Doctor", "specialization": "N/A"}

        # Safely get the user data
        user_data = None
        try:
            if self.userId:
                user_data = self.userId.to_dict()
        except:
            user_data = {"name": "Unknown User", "email": "N/A"}

        return clean_data({
            'id': str(self.id),
            '_id': str(self.id),
            'userId': user_data,
            'dermatologistId': doctor_data,
            'date': getattr(self, 'date', ''),
            'time': getattr(self, 'time', ''),
            'status': getattr(self, 'status', 'pending'),
            'notes': getattr(self, 'notes', ''),
            'adminNote': getattr(self, 'adminNote', ''),
            'patientName': getattr(self, 'patientName', ''),
            'phoneNumber': getattr(self, 'phoneNumber', '')
        })
