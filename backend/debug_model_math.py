import keras
import os
import numpy as np
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
    
    last_layer = model.layers[-1]
    print(f"Last Layer: {last_layer.name}, Activation: {last_layer.activation}")
    
    # Try to calculate logits manually for a zero input to see the bias/tendency
    # Miguel764 uses model.layers[-2].output as input to final_dense
    feat_dim = model.layers[-2].output_shape[-1]
    print(f"Feature Dimension: {feat_dim}")
    
    # Get weights
    weights, biases = last_layer.get_weights()
    print(f"Weights shape: {weights.shape}, Biases shape: {biases.shape}")
    print(f"Biases (Base tendency): {biases}")
    
    # Check normalization by testing a small random image
    dummy_img = np.zeros((1, 224, 224, 3))
    # Test 1: [0, 1] range
    p1 = model.predict(dummy_img, verbose=0)[0]
    print(f"Predict (Zeros): {p1}")
    
    # Test 2: [-1, 1] range (Zeros are still zeros)
    # Test 3: [127, 127, 127] (Middle)
    dummy_mid = np.ones((1, 224, 224, 3)) * 127.0
    p2 = model.predict(dummy_mid, verbose=0)[0] # Raw 127
    print(f"Predict (127 raw): {p2}")
    
    p3 = model.predict(dummy_mid/255.0, verbose=0)[0] # 0.5
    print(f"Predict (0.5 scaled): {p3}")

    p4 = model.predict((dummy_mid/255.0 - 0.5)*2, verbose=0)[0] # 0.0
    print(f"Predict (0.0 shifted): {p4}")

except Exception as e:
    print(f"Error: {e}")
