import os
import cv2
import numpy as np
import tensorflow as tf
from tensorflow import keras

model_path = r"c:\fyp\backend\ai_models\skin_model.keras"
model = keras.models.load_model(model_path)

labels = ["acne", "carcinoma", "eczema", "keratosis", "milia", "rosacea"]

def run_test(img_path):
    print(f"\n--- Testing result for {img_path} ---")
    img = cv2.imread(img_path)
    if img is None:
        print("Image not found!")
        return
    
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_resized = cv2.resize(img_rgb, (224, 224))
    
    # Try different normalizations
    inputs = [
        ("Raw [0, 255]", img_resized.astype('float32')),
        ("Norm [0, 1]", img_resized.astype('float32') / 255.0),
        ("PreprocessV2", tf.keras.applications.efficientnet_v2.preprocess_input(img_resized.astype('float32')))
    ]
    
    for name, inp in inputs:
        preds = model.predict(np.expand_dims(inp, axis=0), verbose=0)[0]
        top_idx = np.argmax(preds)
        print(f"{name}: Pred={labels[top_idx]} ({preds[top_idx]*100:.2f}%)")
        print(f"Full preds: {preds}")

if __name__ == "__main__":
    # Test with dummy ones
    dummy_img = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
    cv2.imwrite("test_dummy.jpg", dummy_img)
    run_test("test_dummy.jpg")
    
    # Also test with one from the uploads if possible
    upload_dir = r"c:\fyp\backend\uploads"
    if os.path.exists(upload_dir):
        files = os.listdir(upload_dir)
        if files:
            run_test(os.path.join(upload_dir, files[-1]))
