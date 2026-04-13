import pytest
import requests
from datetime import datetime, timedelta

# --- CONFIG ---
AUTH_URL = "http://127.0.0.1:5000/api"
APPOINT_URL = "http://127.0.0.1:3000/api"
TEST_EMAIL = "automator@test.com"
TEST_PASS = "testpass123"

@pytest.fixture(scope="module")
def auth_token():
    payload = {"email": TEST_EMAIL, "password": TEST_PASS}
    resp = requests.post(f"{AUTH_URL}/auth/login", json=payload)
    if resp.status_code != 200:
        requests.post(f"{AUTH_URL}/auth/register", json={"name": "AutoBot", "email": TEST_EMAIL, "password": TEST_PASS})
        resp = requests.post(f"{AUTH_URL}/auth/login", json=payload)
    return resp.json().get('token')

def test_get_doctors(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    res = requests.get(f"{APPOINT_URL}/appointments/doctors", headers=headers)
    assert res.status_code == 200
    assert len(res.json()) > 0

def test_book_appointment(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    doc_res = requests.get(f"{APPOINT_URL}/appointments/doctors", headers=headers)
    doctor_id = doc_res.json()[0]['_id']
    
    tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
    payload = {
        "dermatologistId": doctor_id,
        "date": tomorrow,
        "time": "10:00 AM - 11:00 AM",
        "patientName": "AutoBot",
        "phoneNumber": "9800000000"
    }
    res = requests.post(f"{APPOINT_URL}/appointments/book", json=payload, headers=headers)
    assert res.status_code in [201, 409]

def test_verify_history(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    res = requests.get(f"{APPOINT_URL}/appointments/my", headers=headers)
    assert res.status_code == 200
    assert "appointments" in res.json()
