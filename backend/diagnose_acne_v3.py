import os
import sys
import tensorflow as tf

model_path = os.path.join(os.getcwd(), 'ai_models', 'acne')

try:
    print("Attempting tf.saved_model.load with tags...")
    # Sometimes specifying the tag helps
    model = tf.saved_model.load(model_path, tags=[tf.saved_model.SERVING])
    print("SUCCESS: Loaded via tf.saved_model.load")
    
    # Try to find the signature
    infer = model.signatures["serving_default"]
    print(f"Signature found: {infer}")
    
    import numpy as np
    dummy_input = np.random.random((1, 224, 224, 3)).astype('float32')
    # We need to knows the input key
    input_key = list(infer.structured_input_signature[1].keys())[0]
    out = infer(**{input_key: tf.constant(dummy_input)})
    print("Inference Success!")
    
except Exception as e:
    print(f"tf.saved_model.load failed: {e}")
