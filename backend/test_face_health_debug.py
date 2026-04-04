import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from face_health_analyzer import FaceHealthAnalyzer
import time

print("[DEBUG] Creating analyzer...")
analyzer = FaceHealthAnalyzer()
print("[DEBUG] Analyzer created.")

test_img = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_dummy.jpg")
if os.path.exists(test_img):
    print(f"[DEBUG] Analyzing {test_img}...")
    start = time.time()
    res = analyzer.analyze(test_img)
    print(f"[DEBUG] Done in {time.time() - start:.2f}s")
    import json
    print(json.dumps(res, indent=2))
else:
    print(f"[DEBUG] test_dummy.jpg not found at {test_img}")
