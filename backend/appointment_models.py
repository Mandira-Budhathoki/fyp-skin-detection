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
    isFrozen = mongoengine.BooleanField(default=False)
    
    # Engagement Fields
    totalScans = mongoengine.IntField(default=0)
    currentStreak = mongoengine.IntField(default=0)
    lastScanDate = mongoengine.DateTimeField()
    
    meta = {'collection': 'users', 'strict': False}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            '_id': str(self.id),
            'name': getattr(self, 'name', ''),
            'email': getattr(self, 'email', ''),
            'role': getattr(self, 'role', 'user'),
            'isFrozen': getattr(self, 'isFrozen', False),
            'totalScans': getattr(self, 'totalScans', 0),
            'currentStreak': getattr(self, 'currentStreak', 0),
            'lastScanDate': getattr(self, 'lastScanDate', None)
        })

class Dermatologist(mongoengine.DynamicDocument):
    name = mongoengine.StringField(required=True)
    specialization = mongoengine.StringField(required=True)
    isActive = mongoengine.BooleanField(default=True)
    
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
            'availability': getattr(self, 'availability', []),
            'isActive': getattr(self, 'isActive', True)
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

class ChatHistory(mongoengine.DynamicDocument):
    userId = mongoengine.StringField(required=True) # Storing as String for easy lookup
    message = mongoengine.StringField(required=True)
    sender = mongoengine.StringField(required=True) # 'user' or 'bot'
    timestamp = mongoengine.DateTimeField(default=datetime.utcnow)

    meta = {'collection': 'chat_history', 'ordering': ['timestamp']}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            'userId': self.userId,
            'message': self.message,
            'sender': self.sender,
            'timestamp': self.timestamp
        })

class ScanHistory(mongoengine.DynamicDocument):
    userId = mongoengine.StringField(required=True)
    prediction = mongoengine.StringField(required=True)
    confidence = mongoengine.FloatField(required=True)
    imagePath = mongoengine.StringField() # URL or path to the stored image
    timestamp = mongoengine.DateTimeField(default=datetime.utcnow)
    
    meta = {'collection': 'scan_history', 'ordering': ['-timestamp']}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            'userId': self.userId,
            'prediction': self.prediction,
            'confidence': self.confidence,
            'imagePath': self.imagePath,
            'timestamp': self.timestamp
        })

class JournalEntry(mongoengine.DynamicDocument):
    userId = mongoengine.StringField(required=True)
    content = mongoengine.StringField(required=True)
    mood = mongoengine.StringField() # Optional: happy, sad, stressed, etc.
    timestamp = mongoengine.DateTimeField(default=datetime.utcnow)

    meta = {'collection': 'journal_entries', 'ordering': ['-timestamp']}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            'userId': self.userId,
            'content': self.content,
            'mood': self.mood,
            'timestamp': self.timestamp
        })

class VitalityData(mongoengine.DynamicDocument):
    userId = mongoengine.StringField(required=True)
    height = mongoengine.FloatField() # in cm
    weight = mongoengine.FloatField() # in kg
    steps = mongoengine.IntField(default=0)
    sleepHours = mongoengine.FloatField()
    waterIntake = mongoengine.FloatField() # in liters
    sunExposure = mongoengine.FloatField() # in hours
    timestamp = mongoengine.DateTimeField(default=datetime.utcnow)

    meta = {'collection': 'vitality_data', 'ordering': ['-timestamp']}

    def to_dict(self):
        return clean_data({
            'id': str(self.id),
            'userId': self.userId,
            'height': self.height,
            'weight': self.weight,
            'steps': getattr(self, 'steps', 0),
            'sleepHours': self.sleepHours,
            'waterIntake': self.waterIntake,
            'sunExposure': getattr(self, 'sunExposure', 2.0),
            'timestamp': self.timestamp
        })
