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

try:
    print("Attempting tf.keras.layers.TFSMLayer (Keras 3 way)...")
    # This is recommended for Keras 3 when loading legacy SavedModel
    # Note: We wrap it in a Sequential so we can call .predict()
    model = tf.keras.Sequential([
        tf.keras.layers.TFSMLayer(model_path, call_endpoint='serving_default')
    ])
    print("SUCCESS: Loaded via TFSMLayer")
    
    # Test a dummy prediction
    import numpy as np
    dummy_input = np.random.random((1, 224, 224, 3)).astype('float32')
    out = model.predict(dummy_input)
    print(f"Prediction success! Output keys: {out.keys() if isinstance(out, dict) else 'tensor'}")
    
except Exception as e:
    print(f"TFSMLayer load/predict failed: {e}")
    
    try:
        print("Attempting tf.compat.v1.saved_model.load (Legacy/TF1 way)...")
        # Sometimes works for older GitHub models
        with tf.compat.v1.Session() as sess:
            tf.compat.v1.saved_model.loader.load(sess, [tf.saved_model.SERVING], model_path)
            print("SUCCESS: Loaded via tf.compat.v1.loader")
    except Exception as e3:
        print(f"tf.compat.v1 load failed: {e3}")
