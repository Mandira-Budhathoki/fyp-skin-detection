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
        layer = model.layers[-i]
        print(f"Layer -{i}: {layer.name} ({type(layer).__name__})")
        if hasattr(layer, 'activation'):
            print(f"  -> Activation: {layer.activation}")
        if hasattr(layer, 'get_config'):
             print(f"  -> Config: {layer.get_config().get('activation', 'N/A')}")

except Exception as e:
    print(f"Error: {e}")
