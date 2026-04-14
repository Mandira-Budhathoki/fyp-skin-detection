import os
import sys
import mongoengine
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Add current dir to path
sys.path.append(os.getcwd())

from appointment_models import ScanHistory

def inspect_all():
    try:
        mongoengine.connect(host=os.getenv('MONGO_URI'))
        print("Connected to MongoDB")
        
        scans = ScanHistory.objects()
        for i, s in enumerate(scans):
            try:
                s.to_dict()
            except Exception as e:
                print(f"Error on scan {i} (ID: {s.id}): {e}")
        
        print("Inspection complete.")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    inspect_all()
