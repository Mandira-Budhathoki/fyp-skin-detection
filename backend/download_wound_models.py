import os
import requests
from huggingface_hub import snapshot_download

# Define our Wound Ensemble Models
MODELS = {
    # Primary Wound Classifier (Determines Venous, Diabetic, Pressure, Normal, etc.)
    "wound_classifier": "Hemg/Wound-Image-classification",
    # Secondary Classifier for cross-checking (helps achieve the balanced ensemble effect)
    "wound_classifier_secondary": "PayamFard123/dermaintel-wound-classifier"
}

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
AI_MODELS_DIR = os.path.join(BASE_DIR, "ai_models", "hf_models")

def list_files(folder):
    result = []
    for root, dirs, files in os.walk(folder):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for f in files:
            result.append(os.path.join(root, f))
    return result

def download_wound_models():
    print(f"\n📦 Downloading High-Accuracy Wound Ensemble Models...\nTarget: {AI_MODELS_DIR}\n")
    results = {}

    for key, repo_id in MODELS.items():
        target_path = os.path.join(AI_MODELS_DIR, key)
        os.makedirs(target_path, exist_ok=True)
        print(f"🔄 [{key}] Downloading {repo_id}...")
        try:
            snapshot_download(
                repo_id=repo_id,
                local_dir=target_path,
                local_dir_use_symlinks=False,
                ignore_patterns=["*.h5", "flax_model*", "tf_model*", "rust_model*", "*.msgpack"]
            )
            files = list_files(target_path)
            print(f"  ✅ Success: {len(files)} files downloaded.")
            results[key] = "✅ OK"
        except Exception as e:
            print(f"  ❌ Failed: {e}")
            results[key] = f"❌ {e}"

    print("\n============ ENSEMBLE SUMMARY ============")
    for key, status in results.items():
        print(f"  {key.ljust(25)}: {status}")
    print("==========================================\n")
    print("NOTE: Next step for 'Real App' Object Detection (YOLOv8 bounding boxes):")
    print("Download the Medetec/FUSeg balanced dataset from Roboflow Universe to train a YOLO base model.")

if __name__ == "__main__":
    download_wound_models()
