import requests
from datetime import datetime, timedelta

# --- CONFIGURATION ---
AUTH_URL = "http://127.0.0.1:5000/api"      # Node.js Server
APPOINT_URL = "http://127.0.0.1:3000/api"   # Flask Server (Appointments)
TEST_EMAIL = "automator@test.com"
TEST_PASS = "testpass123"

def run_appointment_automation():
    print("--- APPOINTMENT BOOKING AUTOMATION TOOL ---")
    print("-" * 50)

    try:
        # STEP 1: AUTHENTICATION
        print("[1/4] Authenticating with System...")
        login_payload = {"email": TEST_EMAIL, "password": TEST_PASS}
        
        # Try login
        response = requests.post(f"{AUTH_URL}/auth/login", json=login_payload, timeout=5)
        
        if response.status_code != 200:
            print("INFO: Registering test user...")
            requests.post(f"{AUTH_URL}/auth/register", json={"name": "AutoBot", "email": TEST_EMAIL, "password": TEST_PASS}, timeout=5)
            response = requests.post(f"{AUTH_URL}/auth/login", json=login_payload, timeout=5)
        
        token = response.json().get('token')
        headers = {"Authorization": f"Bearer {token}"}
        print("SUCCESS: Logged in and Token retrieved.")

        # STEP 2: FIND A DOCTOR
        print("\n[2/4] Searching for available Doctors...")
        doc_res = requests.get(f"{APPOINT_URL}/appointments/doctors", headers=headers, timeout=5)
        doctors = doc_res.json()
        
        if not doctors:
            print("FAIL: No doctors found. Did you seed the database?")
            return
            
        doctor = doctors[0]
        print(f"SUCCESS: Found Doctor -> {doctor['name']} ({doctor['specialization']})")

        # STEP 3: BOOK AN APPOINTMENT
        print(f"\n[3/4] Attempting to book a slot for tomorrow...")
        tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
        
        booking_payload = {
            "dermatologistId": doctor['_id'],
            "date": tomorrow,
            "time": "10:00 AM - 11:00 AM",
            "notes": "Automated system test run",
            "patientName": "AutoBot",
            "phoneNumber": "9800000000"
        }
        
        book_res = requests.post(f"{APPOINT_URL}/appointments/book", json=booking_payload, headers=headers, timeout=5)
        
        if book_res.status_code == 201:
            print(f"SUCCESS: Appointment booked for {tomorrow} at 10:00 AM!")
        elif book_res.status_code == 409:
            print(f"INFO: Slot is already taken (This means the logic is working perfectly).")
        else:
            print(f"FAIL: Booking error: {book_res.text}")
            return

        # STEP 4: VERIFY IN 'MY APPOINTMENTS'
        print("\n[4/4] Verifying appointment in your History...")
        history_res = requests.get(f"{APPOINT_URL}/appointments/my", headers=headers, timeout=5)
        
        if history_res.status_code == 200:
            appts = history_res.json().get('appointments', [])
            # Check if our new appointment is there
            found = any(a['dermatologistId']['_id'] == doctor['_id'] and a['date'] == tomorrow for a in appts)
            if found:
                print("SUCCESS: Appointment verified in History!")
            else:
                print("FAIL: Appointment not found in history list.")
        else:
            print("FAIL: Could not retrieve history.")

        print("-" * 50)
        print("APPOINTMENT AUTOMATION COMPLETE!")

    except Exception as e:
        print(f"\nCRITICAL ERROR: {str(e)}")
        print("Tip: Make sure both Node (5000) and Flask (3000) are running.")

if __name__ == "__main__":
    run_appointment_automation()
