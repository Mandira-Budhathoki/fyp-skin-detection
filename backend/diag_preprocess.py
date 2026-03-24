"""
Run this diagnostic to see which preprocessing gives best varied results.
Tests ALL 3 methods on 5 recent skin images.
"""
import os
import cv2
import numpy as np
import tensorflow as tf
from tensorflow import keras

model_path = r"c:\fyp\backend\ai_models\skin_model.keras"
labels = ["Acne", "Carcinoma", "Eczema", "Keratosis", "Milia", "Rosacea"]

print("Loading model...")
model = keras.models.load_model(model_path, compile=False)
print(f"Model input shape: {model.input_shape}")
print(f"Model output shape: {model.output_shape}")

# Check if model has a rescaling layer inside
for layer in model.layers[:5]:
    print(f"  Layer: {layer.name} ({type(layer).__name__})")

UPLOAD_DIR = r"c:\fyp\backend\uploads"
skin_files = sorted([f for f in os.listdir(UPLOAD_DIR) if f.startswith("skin_")])[-5:]

print(f"\n=== Testing {len(skin_files)} images with 3 preprocessing methods ===")

for fname in skin_files:
    fpath = os.path.join(UPLOAD_DIR, fname)
    img = cv2.imread(fpath)
    if img is None:
        continue
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_224 = cv2.resize(img_rgb, (224, 224)).astype('float32')

    results = {}
    # Method 1: Raw [0-255]
    p1 = model.predict(np.expand_dims(img_224, 0), verbose=0)[0]
    results["Raw [0-255]"] = p1
    # Method 2: Normalized [0-1]
    p2 = model.predict(np.expand_dims(img_224/255.0, 0), verbose=0)[0]
    results["Norm [0-1]"] = p2
    # Method 3: EfficientNetV2 preprocess ([-1, 1])
    p3 = model.predict(np.expand_dims(tf.keras.applications.efficientnet_v2.preprocess_input(img_224.copy()), 0), verbose=0)[0]
    results["EfficNetV2 [-1,1]"] = p3

    print(f"\n--- {fname} ---")
    for method, preds in results.items():
        top = labels[np.argmax(preds)]
        top_conf = preds[np.argmax(preds)] * 100
        variance = np.var(preds)
        print(f"  {method:22s}: {top:12s} {top_conf:5.1f}%  | variance={variance:.6f} | all={[round(x*100,1) for x in preds]}")

print("\n=== VERDICT ===")
print("Use the method with HIGHEST variance (most spread-out predictions = meaningful = not static)")
