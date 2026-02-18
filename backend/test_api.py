import requests
import json

try:
    response = requests.get('http://127.0.0.1:3000/api/appointments/admin/pending')
    print(f"Status Code: {response.status_code}")
    print("Response Body:")
    print(json.dumps(response.json(), indent=2))
except Exception as e:
    print(f"Error: {str(e)}")
