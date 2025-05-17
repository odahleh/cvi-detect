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

def convert_to_coreml(model_path, output_path):
    # Initialize the same model architecture as in training
    model = models.mobilenet_v2(weights=None)
    model.classifier[1] = torch.nn.Linear(model.last_channel, 3)  # 3 classes
    
    # Load the state dictionary
    model.load_state_dict(torch.load(model_path, map_location='cpu'))
    model.eval()
    
    # Create a sample input
    example_input = torch.rand(1, 3, 224, 224)
    
    # Trace the model
    traced_model = torch.jit.trace(model, example_input)
    
    # Convert to CoreML
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.TensorType(name="input", shape=example_input.shape)],
        classifier_config=ct.ClassifierConfig(['normal', 'moderate', 'severe']),
        convert_to="neuralnetwork",  # For older iOS compatibility
        minimum_deployment_target=ct.target.iOS14  # Target iOS 14
    )
    
    # Save the model
    mlmodel.save(output_path)
    print(f"Model exported to {output_path}")

if __name__ == '__main__':
    convert_to_coreml('models/checkpoints/best_model.pth', 'models/cvi_model.mlpackage') 