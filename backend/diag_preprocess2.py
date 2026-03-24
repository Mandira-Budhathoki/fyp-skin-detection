import os, sys, cv2, numpy as np
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import tensorflow as tf
from tensorflow import keras

model_path = r"c:\fyp\backend\ai_models\skin_model.keras"
labels = ["Acne", "Carcinoma", "Eczema", "Keratosis", "Milia", "Rosacea"]

model = keras.models.load_model(model_path, compile=False)

out = open(r"c:\fyp\backend\diag_result.txt", "w", encoding="utf-8")

out.write(f"Model input: {model.input_shape}\n")
out.write(f"Model output: {model.output_shape}\n")
for layer in model.layers[:5]:
    out.write(f"  Layer: {layer.name} ({type(layer).__name__})\n")

UPLOAD_DIR = r"c:\fyp\backend\uploads"
skin_files = sorted([f for f in os.listdir(UPLOAD_DIR) if f.startswith("skin_")])[-5:]

for fname in skin_files:
    fpath = os.path.join(UPLOAD_DIR, fname)
    img = cv2.imread(fpath)
    if img is None:
        continue
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_224 = cv2.resize(img_rgb, (224, 224)).astype('float32')

    out.write(f"\n--- {fname} ---\n")
    
    # Method 1: Raw [0-255]
    p1 = model.predict(np.expand_dims(img_224, 0), verbose=0)[0]
    out.write(f"  Raw [0-255]      : {labels[np.argmax(p1)]:12s} {p1[np.argmax(p1)]*100:5.1f}% | var={np.var(p1):.6f} | {[round(x*100,1) for x in p1]}\n")
    
    # Method 2: Normalized [0-1]
    p2 = model.predict(np.expand_dims(img_224/255.0, 0), verbose=0)[0]
    out.write(f"  Norm [0-1]       : {labels[np.argmax(p2)]:12s} {p2[np.argmax(p2)]*100:5.1f}% | var={np.var(p2):.6f} | {[round(x*100,1) for x in p2]}\n")
    
    # Method 3: EfficientNetV2 preprocess [-1, 1]
    p3 = model.predict(np.expand_dims(tf.keras.applications.efficientnet_v2.preprocess_input(img_224.copy()), 0), verbose=0)[0]
    out.write(f"  EfficNetV2 [-1,1]: {labels[np.argmax(p3)]:12s} {p3[np.argmax(p3)]*100:5.1f}% | var={np.var(p3):.6f} | {[round(x*100,1) for x in p3]}\n")

out.write("\n=== VERDICT ===\n")
out.write("Use the method with HIGHEST variance = most meaningful predictions\n")
out.close()
print("DONE - see diag_result.txt")
