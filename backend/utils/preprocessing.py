import cv2
import numpy as np

def preprocess_melanoma_image(image_path):
    """
    image_path: path to the uploaded image
    returns: preprocessed 224x224 image ready for model
    """
    # Read image
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError("Image not found or invalid format")
    
    # Convert to HSV
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    # Threshold dark / reddish spots
    lower = np.array([0, 30, 30])       # tweak if needed
    upper = np.array([25, 255, 255])
    mask = cv2.inRange(hsv, lower, upper)
    
    # Find contours
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if contours:
        # Find largest contour
        largest = max(contours, key=cv2.contourArea)
        x, y, w, h = cv2.boundingRect(largest)
        # Crop the image
        img_cropped = img[y:y+h, x:x+w]
    else:
        # If no contours, use original image
        img_cropped = img
    
    # Resize to 224x224
    img_resized = cv2.resize(img_cropped, (224, 224))
    
    # Convert BGR (OpenCV default) to RGB (Model default)
    img_rgb = cv2.cvtColor(img_resized, cv2.COLOR_BGR2RGB)
    
    return img_rgb
