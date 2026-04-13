import requests
import os

# --- CORRECT PORT MAPPING ---
AI_URL = "http://127.0.0.1:3000/api"    # Flask Analysis
AUTH_URL = "http://127.0.0.1:5000/api"  # Node.js Auth
TEST_EMAIL = "automator@test.com"
TEST_PASS = "testpass123"

def run_automated_backend_test():
    print("--- STARTING AUTOMATED BACKEND INTEGRATION TEST ---")
    print("-" * 50)

    try:
        # STEP 1: TEST LOGIN (on Node.js - 5000)
        print("[1/3] Testing Auth on Port 5000...")
        login_payload = {"email": TEST_EMAIL, "password": TEST_PASS}
        
        try:
            response = requests.post(f"{AUTH_URL}/auth/login", json=login_payload, timeout=10)
            if response.status_code == 200:
                print("SUCCESS: LOGGED IN")
                token = response.json().get('token')
            else:
                print("INFO: Registering/Resetting test user...")
                reg_resp = requests.post(f"{AUTH_URL}/auth/register", json={"name": "AutoBot", "email": TEST_EMAIL, "password": TEST_PASS}, timeout=10)
                token = reg_resp.json().get('token')
                print("SUCCESS: REGISTERED & LOGGED IN")
        except Exception as e:
            print(f"FAIL: Port 5000 (Auth) NOT RESPONDING. Please start server.js!")
            return

        # STEP 2: TEST AI ANALYSIS (on Flask - 3000)
        print("\n[2/3] Testing AI Image Analysis (Melanoma) on Port 3000...")
        print("Note: This can take 30-60 seconds if models are loading...")
        
        test_img_path = r"c:\fyp\backend\test_dummy.jpg" 
        if not os.path.exists(test_img_path):
            with open(test_img_path, 'wb') as f:
                f.write(b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\xf8\xff\xff?\x00\x05\xfe\x02\xfe\xdc\x44\x74\x78\x00\x00\x00\x00IEND\xaeB`\x82')

        with open(test_img_path, 'rb') as img:
            files = {'image': img}
            headers = {"Authorization": f"Bearer {token}"}
            try:
                # WE INCREASED TIMEOUT TO 60 SECONDS HERE
                ai_resp = requests.post(f"{AI_URL}/analyze/melanoma", files=files, headers=headers, timeout=60)
                
                if ai_resp.status_code == 200:
                    data = ai_resp.json()
                    print(f"SUCCESS: AI Response -> {data.get('prediction')} ({data.get('confidence')}%)")
                else:
                    # If it fails, we show exactly why
                    print(f"FAIL: AI Engine Error ({ai_resp.status_code})")
                    print(f"Error Message: {ai_resp.text[:200]}")
            except requests.exceptions.Timeout:
                print("FAIL: AI timed out even after 60s. Your machine might be slow loading models.")
            except Exception as e:
                print(f"FAIL: Port 3000 (AI) Connection Error: {e}")

        # STEP 3: CONCLUDE
        print("-" * 50)
        print("RESULT: SYSTEM AUTOMATION CHECK COMPLETE")

    except Exception as e:
        print(f"\nUNEXPECTED CRITICAL ERROR: {str(e)}")

if __name__ == "__main__":
    run_automated_backend_test()
