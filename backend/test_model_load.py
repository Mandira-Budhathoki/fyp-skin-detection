import os
import tensorflow as tf

model_path = r'c:\fyp\backend\ai_models\acne'

print(f"Checking path: {model_path}")
print(f"Exists: {os.path.exists(model_path)}")

if os.path.exists(model_path):
    print(f"Contents: {os.listdir(model_path)}")
    if 'variables' in os.listdir(model_path):
        print(f"Variables contents: {os.listdir(os.path.join(model_path, 'variables'))}")

try:
    print("Attempting to load with tf.keras.models.load_model...")
    model = tf.keras.models.load_model(model_path)
    print("SUCCESS: Loaded with Keras")
except Exception as e1:
    print(f"Keras load failed: {e1}")
    try:
        print("Attempting to load with tf.saved_model.load...")
        model = tf.saved_model.load(model_path)
        print("SUCCESS: Loaded with saved_model")
    except Exception as e2:
        print(f"SavedModel load failed: {e2}")
