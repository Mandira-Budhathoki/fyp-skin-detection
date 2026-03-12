import os
import sys

# Add the current directory to path
sys.path.append(os.getcwd())

try:
    import tensorflow as tf
    print(f"TensorFlow version: {tf.__version__}")
except ImportError:
    print("TensorFlow NOT INSTALLED")
    sys.exit(1)

model_path = os.path.join(os.getcwd(), 'ai_models', 'acne')
print(f"Checking model at: {model_path}")

if not os.path.exists(model_path):
    print("ERROR: Folder does not exist")
else:
    print(f"Folder exists. Contents: {os.listdir(model_path)}")
    
    try:
        print("Attempting tf.keras.models.load_model...")
        model = tf.keras.models.load_model(model_path)
        print("SUCCESS: Loaded via Keras")
    except Exception as e:
        print(f"Keras load failed: {e}")
        
        try:
            print("Attempting tf.saved_model.load...")
            model = tf.saved_model.load(model_path)
            print("SUCCESS: Loaded via SavedModel")
        except Exception as e2:
            print(f"SavedModel load failed: {e2}")
