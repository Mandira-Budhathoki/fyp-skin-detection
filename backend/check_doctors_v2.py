import mongoengine
import os
from dotenv import load_dotenv
from appointment_models import Dermatologist

# Load .env
load_dotenv()

# Connect to MongoDB using the URI from .env
uri = os.getenv('MONGO_URI')
print(f"Connecting to: {uri[:20]}...") # Print only start of URI for safety

try:
    mongoengine.connect(host=uri)
    print("Connected successfully!")
    
    active_count = Dermatologist.objects(isActive=True).count()
    total_count = Dermatologist.objects.count()

    print(f"Total Doctors: {total_count}")
    print(f"Active Doctors: {active_count}")

    for doc in Dermatologist.objects[:5]: # Only first 5
        print(f"Name: {doc.name}, Active: {getattr(doc, 'isActive', 'N/A')}")
except Exception as e:
    print(f"Error: {e}")
