import pytest
import requests
import os
from datetime import datetime, timedelta

# --- CONFIG ---
AI_URL = "http://127.0.0.1:3000/api"
AUTH_URL = "http://127.0.0.1:5000/api"
TEST_EMAIL = "automator@test.com"
TEST_PASS = "testpass123"

@pytest.fixture(scope="module")
def auth_token():
    """Professional Pytest Fixture to handle login for all tests"""
    payload = {"email": TEST_EMAIL, "password": TEST_PASS}
    resp = requests.post(f"{AUTH_URL}/auth/login", json=payload)
    if resp.status_code != 200:
        requests.post(f"{AUTH_URL}/auth/register", json={"name": "AutoBot", "email": TEST_EMAIL, "password": TEST_PASS})
        resp = requests.post(f"{AUTH_URL}/auth/login", json=payload)
    return resp.json().get('token')

def test_melanoma_analysis(auth_token):
    """Test Case 1: Melanoma AI Engine"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    with open(r"c:\fyp\backend\test_dummy.jpg", 'rb') as img:
        res = requests.post(f"{AI_URL}/analyze/melanoma", files={'image': img}, headers=headers)
    assert res.status_code == 200
    assert "prediction" in res.json()

def test_acne_analysis(auth_token):
    """Test Case 2: Acne AI Engine"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    with open(r"c:\fyp\backend\test_dummy.jpg", 'rb') as img:
        res = requests.post(f"{AI_URL}/analyze/acne", files={'image': img}, headers=headers)
    assert res.status_code == 200
    assert "confidence" in res.json()

def test_appointment_booking(auth_token):
    """Test Case 3: Clinical Appointment Flow"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    # Get Doctor
    doc_res = requests.get(f"{AI_URL}/appointments/doctors", headers=headers)
    assert doc_res.status_code == 200
    doctor_id = doc_res.json()[0]['_id']
    
    # Book
    tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
    payload = {
        "dermatologistId": doctor_id,
        "date": tomorrow,
        "time": "10:00 AM - 11:00 AM",
        "patientName": "AutoBot",
        "phoneNumber": "9800000000"
    }
    book_res = requests.post(f"{AI_URL}/appointments/book", json=payload, headers=headers)
    assert book_res.status_code in [201, 409] # 409 is also fine (already booked)

def test_history_retrieval(auth_token):
    """Test Case 4: Verify History Retrieval"""
    headers = {"Authorization": f"Bearer {auth_token}"}
    res = requests.get(f"{AI_URL}/appointments/my", headers=headers)
    assert res.status_code == 200
    assert "appointments" in res.json()
