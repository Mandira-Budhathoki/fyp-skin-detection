import tensorflow as tf
from tensorflow import keras
import numpy as np
import os

model_path = r"c:\fyp\backend\ai_models\skin_model.keras"
model = keras.models.load_model(model_path)

# Let's check config for class names or order
if hasattr(model, 'layers'):
    print(f"Number of layers: {len(model.layers)}")
    for layer in model.layers[-10:]:
        print(f"Layer: {layer.name}, Type: {type(layer)}")

# If it's a Sequential model, it might have metadata
# Let's try to get more info
print(f"Input shape: {model.input_shape}")
print(f"Output shape: {model.output_shape}")

# Let's try to find class names in config if available
import json
config = model.get_config()
# Sometimes it's in the last layer
# print(json.dumps(config, indent=2))
