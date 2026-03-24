import keras
import os
from keras.layers import DepthwiseConv2D

class CustomDepthwiseConv2D(DepthwiseConv2D):
    def __init__(self, **kwargs):
        if 'groups' in kwargs:
            del kwargs['groups']
        super().__init__(**kwargs)

model_path = r'C:\fyp\backend\ai_models\efficientnetv2s.h5'
try:
    with keras.utils.custom_object_scope({'DepthwiseConv2D': CustomDepthwiseConv2D}):
        model = keras.models.load_model(model_path)
    
    print("\n--- Model Tail Analysis ---")
    for i in range(1, 6):
        idx = len(model.layers) - i
        layer = model.layers[idx]
        print(f"Layer index {idx} (Negative index -{i}): {layer.name}")
        if hasattr(layer, 'activation'):
            act = layer.activation
            if callable(act):
                print(f"  -> Activation function: {act.__name__ if hasattr(act, '__name__') else act}")
            else:
                print(f"  -> Activation: {act}")
        
    # Check specifically if the last layer has softmax
    last_layer = model.layers[-1]
    config = last_layer.get_config()
    print(f"\nLast layer config activation: {config.get('activation')}")

except Exception as e:
    print(f"Error: {e}")
