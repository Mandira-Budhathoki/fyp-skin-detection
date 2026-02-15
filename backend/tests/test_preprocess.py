from preprocessing.preprocess import preprocess_image

img_path = "../uploads/sample.jpg"  # <- relative path from tests folder

tensor = preprocess_image(img_path)
print("Processed image tensor shape:", tensor.shape)
