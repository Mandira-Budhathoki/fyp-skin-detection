"""
Downloads all 7 Hugging Face models into ai_models/hf_models/<model_name>
Uses local_dir for proper file placement (no symlinks, no metadata issues).
"""
import os
from huggingface_hub import snapshot_download

MODELS = {
    "skin_type":   "dima806/skin-type",
    "acne_severity": "naamalia23/acne-severity",
    "spots":       "afscomercial/dermatologic",
    "inflammation":"Siraja704/DermaAI",
    "face_shape":  "fahd9999/face_shape_classification",
    "gender":      "dima806/facial_gender_image_detection",
    "emotions":    "dima806/facial_emotions_image_detection"
}

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
AI_MODELS_DIR = os.path.join(BASE_DIR, "ai_models", "hf_models")

def list_files(folder):
    result = []
    for root, dirs, files in os.walk(folder):
        # Skip hidden cache dirs
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for f in files:
            if not f.endswith('.metadata'):
                result.append(os.path.join(root, f))
    return result

def download_models():
    print(f"\n📁 Target base: {AI_MODELS_DIR}\n")
    results = {}

    for key, repo_id in MODELS.items():
        target_path = os.path.join(AI_MODELS_DIR, key)
        os.makedirs(target_path, exist_ok=True)
        print(f"📦 [{key}] Downloading {repo_id}...")
        try:
            snapshot_download(
                repo_id=repo_id,
                local_dir=target_path,
                local_dir_use_symlinks=False,
                ignore_patterns=["*.h5", "flax_model*", "tf_model*", "rust_model*"]  # skip huge files we don't need
            )
            files = list_files(target_path)
            print(f"  ✅ {len(files)} files downloaded:")
            for f in files:
                size = os.path.getsize(f)
                print(f"     - {os.path.relpath(f, target_path)} ({size/1024/1024:.2f} MB)")
            results[key] = "✅ OK"
        except Exception as e:
            print(f"  ❌ Failed: {e}")
            results[key] = f"❌ {e}"

    print("\n============ SUMMARY ============")
    for key, status in results.items():
        print(f"  {key}: {status}")
    print("=================================\n")

if __name__ == "__main__":
    download_models()
