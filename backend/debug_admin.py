from main_server import app
from appointment_routes import get_pending_appointments
import traceback

with app.test_request_context():
    try:
        response, code = get_pending_appointments()
        print(f"Code: {code}")
        # Trying to force serialization check
        import json
        json.dumps(response.get_json())
        print("Success: Data is serializable")
        print(f"Data: {response.get_json()}")
    except Exception as e:
        print(f"FAILED: {str(e)}")
        traceback.print_exc()
