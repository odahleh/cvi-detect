import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import os
import numpy as np
from flask import Flask, request, jsonify
import io
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from models.segment_leg import segment_leg

app = Flask(__name__)

# Configuration
MODEL_CHECKPOINT_PATH = 'models/checkpoints/best_model.pth' # Adjusted path
CLASS_NAMES = ['normal', 'moderate', 'severe'] # As per visualize.py
DEVICE = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
print(f"Using device: {DEVICE}")

# Global model variable
model_ft = None

def load_model():
    global model_ft
    model_ft = models.mobilenet_v2(pretrained=False) # Or True if you used a pretrained base
    model_ft.classifier[1] = nn.Linear(model_ft.last_channel, len(CLASS_NAMES))
    
    if os.path.exists(MODEL_CHECKPOINT_PATH):
        try:
            # Load checkpoint compatible with the device
            model_ft.load_state_dict(torch.load(MODEL_CHECKPOINT_PATH, map_location=DEVICE))
            print(f"Loaded model checkpoint from {MODEL_CHECKPOINT_PATH}")
        except Exception as e:
            print(f"Error loading model checkpoint: {e}")
            model_ft = None # Ensure model is None if loading fails
    else:
        print(f"Error: Checkpoint not found at {MODEL_CHECKPOINT_PATH}")
        model_ft = None
    
    if model_ft:
        model_ft = model_ft.to(DEVICE)
        model_ft.eval() # Set model to evaluation mode

# Data transforms (should match the validation transforms from training)
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

@app.route('/predict', methods=['POST'])
def predict():
    if model_ft is None:
        return jsonify({"error": "Model not loaded. Check server logs."}), 500

    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    if file:
        try:
            # Save the uploaded file temporarily
            temp_dir = "temp_uploads"
            os.makedirs(temp_dir, exist_ok=True)
            temp_image_path = os.path.join(temp_dir, file.filename)
            file.save(temp_image_path)

            # --- Adapted predict_single_image logic ---
            image_for_inference = None
            segmented_image_path = os.path.join(temp_dir, f"{os.path.splitext(file.filename)[0]}_segmented.jpg")

            try:
                # segment_leg expects paths, so we use the saved temp_image_path
                segmented_image_pil = segment_leg(temp_image_path, segmented_image_path, visualize_seeds=False)
                if isinstance(segmented_image_pil, str): # If segment_leg returns a path
                     image_for_inference = Image.open(segmented_image_pil).convert('RGB')
                else: # If segment_leg returns a PIL image
                     image_for_inference = segmented_image_pil.convert('RGB')
                print(f"Segmented image processed.")
            except Exception as e:
                print(f"Segmentation failed: {e}. Using original image.")
                image_for_inference = Image.open(temp_image_path).convert('RGB')
            
            # Preprocess the image
            input_tensor = transform(image_for_inference).unsqueeze(0).to(DEVICE)
            
            # Run inference
            with torch.no_grad():
                output = model_ft(input_tensor)
                probabilities = torch.nn.functional.softmax(output, dim=1)[0]
            
            probs_np = probabilities.cpu().numpy()
            
            # Prepare response
            response_data = {
                "filename": file.filename,
                "probabilities": {CLASS_NAMES[i]: float(probs_np[i]) for i in range(len(CLASS_NAMES))},
                "predicted_class_index": int(np.argmax(probs_np)),
                "predicted_class_name": CLASS_NAMES[np.argmax(probs_np)]
            }
            
            # Clean up temporary files
            try:
                os.remove(temp_image_path)
                if os.path.exists(segmented_image_path):
                    os.remove(segmented_image_path)
            except OSError as e:
                print(f"Error removing temporary files: {e}")

            return jsonify(response_data)

        except Exception as e:
            # Log the full exception for debugging
            app.logger.error(f"Error during prediction: {e}", exc_info=True)
            return jsonify({"error": "Error processing image", "details": str(e)}), 500
            
    return jsonify({"error": "File processing failed"}), 500

if __name__ == '__main__':
    load_model() # Load the model when the script starts
    if model_ft is None:
        print("Failed to load the model. API will not work correctly.")
    # Make sure to create 'temp_uploads' directory if it doesn't exist
    os.makedirs("temp_uploads", exist_ok=True)
    app.run(debug=True, host='0.0.0.0', port=5001) 