import requests
import json

urls = [
    "https://huggingface.co/ahishamm/vit-base-binary-isic-patch-16/raw/main/config.json",
    "https://huggingface.co/ahishamm/vit-base-16-thesis-demo-ISIC-multi-class/raw/main/config.json",
    "https://huggingface.co/oscar2525mv/isic2018-melanoma-vit-baseline/raw/main/config.json"
]

results = {}
for i, url in enumerate(urls):
    try:
        conf = requests.get(url).json()
        results[f"Model_{i}"] = {"url": url, "labels": conf.get("id2label")}
    except:
        pass

with open("c:\\fyp\\models_config.json", "w") as f:
    json.dump(results, f, indent=2)
