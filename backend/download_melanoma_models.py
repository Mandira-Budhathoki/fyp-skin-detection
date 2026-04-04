import os
from huggingface_hub import snapshot_download

def download_melanoma_models():
    models = {
        "melanoma_binary": "oscar2525mv/isic2018-melanoma-vit-baseline",
        "melanoma_multi": "ahishamm/vit-base-16-thesis-demo-ISIC-multi-class"
    }

    base_dir = os.path.dirname(os.path.abspath(__file__))
    target_base = os.path.join(base_dir, "ai_models", "hf_models")

    for model_key, repo_id in models.items():
        print(f"Downloading {repo_id}...")
        save_dir = os.path.join(target_base, model_key)
        snapshot_download(
            repo_id=repo_id,
            local_dir=save_dir,
            local_dir_use_symlinks=False,
            ignore_patterns=["*.h5", "flax_model*", "tf_model*", "rust_model*", "*.msgpack"]
        )
        print(f"Saved to {save_dir}")

if __name__ == "__main__":
    download_melanoma_models()
