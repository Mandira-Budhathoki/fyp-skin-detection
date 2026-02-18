import os
import mongoengine
from dotenv import load_dotenv
from appointment_models import Appointment, User, Dermatologist

load_dotenv()

mongoengine.connect(host=os.getenv('MONGO_URI'))

appointments = Appointment.objects(status='pending')
print(f"Pending appointments found: {len(appointments)}")

for i, appt in enumerate(appointments):
    try:
        data = appt.to_dict()
        print(f"{i+1}. SUCCESS: {appt.id}")
    except Exception as e:
        print(f"{i+1}. FAILED: {appt.id} - Error: {str(e)}")
        import traceback
        traceback.print_exc()
