import mongoengine
import os
from dotenv import load_dotenv
from appointment_models import Dermatologist

# Load .env
load_dotenv()
MONGO_URI = os.getenv('MONGO_URI')

def run_seed():
    print("Connecting to MongoDB...")
    mongoengine.connect(host=MONGO_URI)
    
    print("Deleting old doctors...")
    Dermatologist.objects().delete()

    print("Seeding new doctors with 1-hour slots...")
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

    print("Database seeded successfully with 1-hour slots!")

if __name__ == "__main__":
    run_seed()
