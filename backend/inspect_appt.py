import os
import json
import mongoengine
from dotenv import load_dotenv
from appointment_models import Appointment, User, Dermatologist

load_dotenv()

mongoengine.connect(host=os.getenv('MONGO_URI'))

appointments = Appointment.objects(status='pending')
print(f"Pending appointments found: {len(appointments)}")

if len(appointments) > 0:
    appt = appointments[0]
    data = appt.to_dict()
    print("Appointment to_dict() output:")
    print(json.dumps(data, indent=2))
else:
    print("No pending appointments to inspect.")
