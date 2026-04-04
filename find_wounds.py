import requests

url = "https://huggingface.co/api/models?search=wound&limit=50"
response = requests.get(url)
models = response.json()

results = []
for model in models:
    if "pipeline_tag" in model and model["pipeline_tag"] in ["image-classification", "object-detection", "image-segmentation"]:
        results.append({
            "id": model["id"], 
            "downloads": model.get("downloads", 0),
            "task": model["pipeline_tag"],
            "likes": model.get("likes", 0)
        })

results.sort(key=lambda x: x["downloads"], reverse=True)

import json
with open("wound_models.json", "w") as f:
    json.dump(results[:15], f, indent=2)
