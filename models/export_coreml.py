import torch
import torch.nn as nn
import coremltools as ct
from torchvision import models
import numpy as np
import os

# Define the model architecture (same as in training)
def create_model():
    model = models.mobilenet_v2(weights=None)  # Updated from pretrained=False
    model.classifier[1] = nn.Linear(model.last_channel, 3)  # 3 classes
    return model

def convert_to_coreml():
    # Create model and load checkpoint
    model = create_model()
    
    checkpoint_path = 'models/checkpoints/best_model.pth'
    if not os.path.exists(checkpoint_path):
        print(f"Error: Checkpoint not found at {checkpoint_path}")
        return
    
    # Load weights
    model.load_state_dict(torch.load(checkpoint_path, map_location='cpu'))
    model.eval()
    
    # Create example input
    example_input = torch.rand(1, 3, 224, 224)
    
    # Trace the model
    traced_model = torch.jit.trace(model, example_input)
    
    # Define class labels
    class_labels = ['normal', 'moderate', 'severe']
    
    # Convert to Core ML
    # Create the input tensor without description
    input_tensor = ct.TensorType(name="input", shape=example_input.shape)
    
    try:
        mlmodel = ct.convert(
            traced_model,
            inputs=[input_tensor],
            classifier_config=ct.ClassifierConfig(class_labels),
            minimum_deployment_target=ct.target.iOS15
        )
        
        # Try to add metadata in a more compatible way
        try:
            mlmodel.short_description = "CVI Detection from images of legs"
            mlmodel.author = "CVI-Detect Team"
            mlmodel.license = "MIT"
            print("Added metadata to the model")
        except Exception as e:
            print(f"Warning: Could not add metadata: {e}")
        
        # Save the model
        os.makedirs('models/output', exist_ok=True)
        mlmodel.save("models/output/CVIDetect.mlmodel")
        print("Model converted and saved as models/output/CVIDetect.mlmodel")
        
    except Exception as e:
        # Fallback method if the above fails
        print(f"Error with primary conversion method: {e}")
        print("Trying alternative conversion method...")
        
        try:
            # Simpler conversion without additional parameters
            mlmodel = ct.convert(
                traced_model,
                inputs=[input_tensor],
                classifier_config=ct.ClassifierConfig(class_labels)
            )
            
            # Save the model
            os.makedirs('models/output', exist_ok=True)
            mlmodel.save("models/output/CVIDetect.mlmodel")
            print("Model converted using fallback method and saved as models/output/CVIDetect.mlmodel")
        except Exception as e2:
            print(f"Both conversion methods failed. Error: {e2}")

if __name__ == "__main__":
    convert_to_coreml() 