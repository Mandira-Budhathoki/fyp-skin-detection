import os
import io
import torch
import numpy as np
import traceback
from PIL import Image
from transformers import pipeline

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, 'ai_models', 'hf_models')

# The Ensemble approach
WOUND_MODELS = {
    # 1. Primary Classification
    "primary": {
        "dir": os.path.join(MODELS_DIR, "wound_classifier"),
        "task": "image-classification",
    },
    # 2. Secondary/Cross-Check Classification
    "secondary": {
        "dir": os.path.join(MODELS_DIR, "wound_classifier_secondary"),
        "task": "image-classification",
    }
}

class WoundAnalyzerEngine:
    def __init__(self):
        self.pipelines = {}
        # Ensure CPU fallback and MPS/CUDA if available
        self.device = torch.device(
            "cuda" if torch.cuda.is_available() 
            else "mps" if torch.backends.mps.is_available() 
            else "cpu"
        )
        print(f"[WoundAnalyzer] Initializing ensemble on device: {self.device}")
        
        self._load_ensemble()

    def _load_ensemble(self):
        """Loads all available HuggingFace models for the ensemble."""
        for key, info in WOUND_MODELS.items():
            model_path = info["dir"]
            # To ensure it falls back gracefully if models aren't downloaded yet.
            if os.path.exists(model_path) and len(os.listdir(model_path)) > 0:
                print(f"[WoundAnalyzer] Loading {key} model...")
                try:
                    pipe = pipeline(
                        info["task"],
                        model=model_path,
                        device=0 if self.device.type != "cpu" else -1
                    )
                    self.pipelines[key] = pipe
                    print(f"  [SUCCESS] {key.capitalize()} model loaded successfully.")
                except Exception as e:
                    print(f"  [ERROR] Error loading {key} model: {e}")
            else:
                print(f"  [WARNING] Model '{key}' not found at {model_path}. Please run download_wound_models.py")

    def generate_recommendations(self, results):
        """Generates first-aid and care instructions based on wound detection."""
        recommendations = []
        primary = results.get("primary")
        if not primary or "Unclear" in primary["label"]:
            return []

        label = primary["label"].lower()
        
        # 1. Condition Specific Advice
        if "burn" in label:
            recommendations.append({
                "title": "Burn First Aid",
                "type": "urgent",
                "icon": "fire",
                "description": "Run cool (not cold) water over the area for 10-20 minutes. Avoid ice, butter, or ointments which can trap heat. Cover loosely with sterile gauze."
            })
        elif "laceration" in label or "cut" in label:
            recommendations.append({
                "title": "Bleeding Control",
                "type": "urgent",
                "icon": "medical",
                "description": "Apply steady, direct pressure with a clean cloth. Clean the area with mild soap and water once bleeding stops. Seek stitches if the cut is deep or gaping."
            })
        elif "bruise" in label or "contusion" in label:
            recommendations.append({
                "title": "R.I.C.E Method",
                "type": "health",
                "icon": "sunny",
                "description": "Rest the area, apply Ice (wrapped in a towel) for 15 mins, use Compression wrap, and Elevate the limb to reduce swelling and pain."
            })
        
        # 2. Infection Prevention (General)
        recommendations.append({
            "title": "Infection Watch",
            "type": "treatment",
            "icon": "warning",
            "description": "Monitor for 'The Four Signs': increased redness, warmth, swelling, or foul-smelling discharge. If these occur, consult a doctor immediately."
        })

        return recommendations

    def analyze(self, image_bytes: bytes) -> dict:
        """
        Runs the ensemble on the image bytes and consolidates the results.
        Returns a dictionary suitable for NDJSON streaming.
        """
        results = {
            "primary": None,
            "secondary": None,
            "engine_status": "Online",
            "error": None
        }
        
        try:
            # 1. Load and Optimize Image for ViT (224x224 Center Crop)
            # This is the 'optimum best' preprocessing for these specific models.
            image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
            
            # Simple center crop to keep aspect ratio while getting 224x224
            width, height = image.size
            new_size = min(width, height)
            left = (width - new_size) / 2
            top = (height - new_size) / 2
            right = (width + new_size) / 2
            bottom = (height + new_size) / 2
            image = image.crop((left, top, right, bottom))
            image = image.resize((224, 224), Image.LANCZOS)

            # 2. Run Ensemble with Confidence Filtering
            # We ignore matches below 40% confidence as they are often 'noise' or random images
            THRESHOLD = 0.40
            
            # Run Primary
            if "primary" in self.pipelines:
                preds = self.pipelines["primary"](image)
                score = preds[0]["score"] if preds else 0.0
                if score >= THRESHOLD:
                    results["primary"] = {
                        "label": preds[0]["label"],
                        "score": round(float(score) * 100, 2)
                    }
                else:
                    # Explicitly mark as invalid if even the primary model is confused
                    results["primary"] = {"label": "Unclear Image / Not a Wound", "score": round(float(score) * 100, 2)}
                    
            # Run Secondary
            if "secondary" in self.pipelines:
                preds = self.pipelines["secondary"](image)
                score = preds[0]["score"] if preds else 0.0
                if score >= THRESHOLD:
                    results["secondary"] = {
                        "label": preds[0]["label"],
                        "score": round(float(score) * 100, 2)
                    }
                else:
                    results["secondary"] = {"label": "Unclear Image / Not a Wound", "score": round(float(score) * 100, 2)}

        except Exception as e:
            traceback.print_exc()
            results["engine_status"] = "Offline"
            results["error"] = str(e)
            
        # [INFO] GENERATE DYNAMIC RECOMMENDATIONS
        results["recommendations"] = self.generate_recommendations(results)
            
        return results

# Singleton instance
wound_engine = WoundAnalyzerEngine()
