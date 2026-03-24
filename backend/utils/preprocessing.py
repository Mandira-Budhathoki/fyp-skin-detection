import cv2
import numpy as np

def preprocess_melanoma_image(image_path):
    """
    Preprocess image for EfficientNetV2S melanoma model.
    Steps: Alpha removal, Grayscale handling, Aspect-preserving resize (224x224),
    CLAHE contrast enhancement, Mild Gaussian blur, BGR to RGB.
    """
    # Read image including potential alpha channel
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise ValueError("Image not found or invalid format")
    
    # 1. Handle Channels (Remove Alpha, handle Grayscale)
    if len(img.shape) == 2:
        # Grayscale -> BGR
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    elif len(img.shape) == 3 and img.shape[2] == 4:
        # BGRA -> BGR
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
    
    # Convert BGR to RGB
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Miguel764 uses a simple resize to 224x224 (stretch per load_img behavior)
    # Removing padding and extra filters to match original training
    final_img = cv2.resize(img_rgb, (224, 224), interpolation=cv2.INTER_AREA)
    
    return final_img
