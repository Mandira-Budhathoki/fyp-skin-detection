import .
import requests
import os

# --- CONFIG ---
AI_URL = "http://127.0.0.1:3000/api"
AUTH_URL = "http://127.0.0.1:5000/api"
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

def test_melanoma_ai(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    with open(r"c:\fyp\backend\test_dummy.jpg", 'rb') as img:
        res = requests.post(f"{AI_URL}/analyze/melanoma", files={'image': img}, headers=headers)
    assert res.status_code == 200
    assert "prediction" in res.json()

def test_acne_ai(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    with open(r"c:\fyp\backend\test_dummy.jpg", 'rb') as img:
        res = requests.post(f"{AI_URL}/analyze/acne", files={'image': img}, headers=headers)
    assert res.status_code == 200
    assert "prediction" in res.json()

def test_face_health_ai(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    with open(r"c:\fyp\backend\test_dummy.jpg", 'rb') as img:
        res = requests.post(f"{AI_URL}/analyze/face-health", files={'image': img}, headers=headers)
    
    # We allow 200 (Success) OR 400 (if it correctly identifies no face is present)
    assert res.status_code in [200, 400]
    if res.status_code == 200:
        assert "acne" in res.json()
    else:
        assert "error" in res.json() or "fail" in res.json().get('status', '')
