import sys
import os
import torch
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

base_dir = os.path.dirname(os.path.abspath(__file__))
hf_dir = os.path.join(base_dir, "ai_models", "hf_models")
fs_path = os.path.join(hf_dir, "face_shape", "model_85_nn_.pth")

print(f"[CHECK] Checking face_shape at {fs_path}")
if not os.path.exists(fs_path):
    print("[ERROR] File does not exist")
else:
    try:
        device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"[CHECK] Loading on {device} with weights_only=False...")
        model = torch.load(fs_path, map_location=torch.device('cpu'), weights_only=False)
        print("[SUCCESS] Loaded to CPU")
        model = model.to(device)
        print(f"[SUCCESS] Moved to {device}")
        
    except Exception as e:
        print(f"[ERROR] Loading failed: {e}")
        import traceback
        traceback.print_exc()
