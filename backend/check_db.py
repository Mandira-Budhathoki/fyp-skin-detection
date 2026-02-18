import os
import mongoengine
from dotenv import load_dotenv

load_dotenv()

mongoengine.connect(host=os.getenv('MONGO_URI'))

class Appointment(mongoengine.DynamicDocument):
    meta = {'collection': 'appointments', 'strict': False}

appointments = Appointment.objects.all()
print(f"Total appointments found: {len(appointments)}")

for i, appt in enumerate(appointments):
    print(f"{i+1}. ID: {appt.id}, Status: {getattr(appt, 'status', 'N/A')}, Date: {getattr(appt, 'date', 'N/A')}, Time: {getattr(appt, 'time', 'N/A')}")

if len(appointments) == 0:
    print("No appointments found in the 'appointments' collection.")
else:
    pending = [a for a in appointments if getattr(a, 'status', '') == 'pending']
    print(f"Pending appointments count: {len(pending)}")
