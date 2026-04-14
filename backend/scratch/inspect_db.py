import os
import sys
import mongoengine
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Add current dir to path
sys.path.append(os.getcwd())

from appointment_models import ScanHistory

def inspect():
    try:
        mongoengine.connect(host=os.getenv('MONGO_URI'))
        print("Connected to MongoDB")
        
        count = ScanHistory.objects.count()
        print(f"Total scans: {count}")
        
        if count > 0:
            last = ScanHistory.objects.order_by('-timestamp').first()
            print(f"Last Scan: {last.to_dict()}")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    inspect()
