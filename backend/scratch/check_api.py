import requests
import sys

def check():
    try:
        r = requests.get("http://localhost:3000/")
        print(f"Status: {r.status_code}")
        print(f"Body: {r.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check()
