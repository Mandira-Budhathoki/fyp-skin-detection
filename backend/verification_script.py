import requests
import time

BASE_URL = "http://127.0.0.1:5000/api"

def test_workflow():
    print("Testing Workflow...")
    
    # 1. Login
    print("\n1. Login (Mock)")
    login_resp = requests.post(f"{BASE_URL}/auth/login", json={"email": "test@example.com", "password": "pass"})
    if login_resp.status_code != 200:
        print(f"Login failed: {login_resp.text}")
        return
    token = login_resp.json().get('token')
    headers = {"Authorization": f"Bearer {token}"}
    print(f"Logged in, token: {token}")

    # 2. Get Doctors
    print("\n2. Get Doctors")
    doctors_resp = requests.get(f"{BASE_URL}/appointments/doctors", headers=headers)
    if doctors_resp.status_code != 200:
        print(f"Get Doctors failed: {doctors_resp.text}")
        return
    doctors = doctors_resp.json()
    print(f"Found {len(doctors)} doctors.")
    if not doctors:
        print("No doctors found, seeding failed?")
        return
    
    doctor_id = doctors[0]['_id']
    print(f"Selected Doctor ID: {doctor_id}")

    # 3. Book Appointment
    print("\n3. Book Appointment")
    booking_payload = {
        "dermatologistId": doctor_id,
        "date": "2024-12-25",
        "time": "10:00",
        "notes": "Test appointment"
    }
    book_resp = requests.post(f"{BASE_URL}/appointments/book", json=booking_payload, headers=headers)
    if book_resp.status_code == 201:
        print("Booking successful!")
        appt_id = book_resp.json()['appointment']['_id']
    elif book_resp.status_code == 409:
        print("Slot already booked (expected if re-running without cleanup).")
        # Try finding the existing appointment to proceed
        my_appt_resp = requests.get(f"{BASE_URL}/appointments/my", headers=headers)
        my_appts = my_appt_resp.json()
        matching = [a for a in my_appts if a['dermatologistId']['_id'] == str(doctor_id) and a['date'] == "2024-12-25" and a['time'] == "10:00"]
        if matching:
             appt_id = matching[0]['_id']
             print(f"Found existing appointment ID: {appt_id}")
        else:
             print("Could not find existing appointment ID.")
             return
    else:
        print(f"Booking failed: {book_resp.text}")
        return

    # 4. Get My Appointments
    print("\n4. Get My Appointments")
    my_resp = requests.get(f"{BASE_URL}/appointments/my", headers=headers)
    if my_resp.status_code == 200:
        print(f"My appointments count: {len(my_resp.json())}")
    else:
        print(f"Get My Appointments failed: {my_resp.text}")

    # 5. Get Booked Slots
    print("\n5. Get Booked Slots")
    slots_resp = requests.get(f"{BASE_URL}/appointments/doctors/{doctor_id}/slots?date=2024-12-25", headers=headers)
    if slots_resp.status_code == 200:
        slots = slots_resp.json()['bookedSlots']
        print(f"Booked slots for 2024-12-25: {slots}")
        if "10:00" in slots:
            print("Verified: 10:00 is booked.")
        else:
            print("Error: 10:00 should be booked!")
    else:
        print(f"Get Booked Slots failed: {slots_resp.text}")

    # 6. Cancel Appointment
    print(f"\n6. Cancel Appointment {appt_id}")
    cancel_resp = requests.delete(f"{BASE_URL}/appointments/{appt_id}", headers=headers)
    if cancel_resp.status_code == 200:
        print("Cancellation successful!")
    else:
        print(f"Cancellation failed: {cancel_resp.text}")

    # Verify cancellation
    slots_resp_after = requests.get(f"{BASE_URL}/appointments/doctors/{doctor_id}/slots?date=2024-12-25", headers=headers)
    if "10:00" not in slots_resp_after.json()['bookedSlots']:
        print("Verified: 10:00 is free again.")
    else:
        print("Error: 10:00 is still booked!")

if __name__ == "__main__":
    try:
        test_workflow()
    except Exception as e:
        print(f"Test failed with exception: {e}")
