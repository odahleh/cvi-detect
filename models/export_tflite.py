import torch
import tensorflow as tf
import numpy as np
from torchvision import models, transforms
from train import CVIDataset

def convert_to_tflite(model_path, output_path):
    # Initialize the same model architecture as in training
    model = models.mobilenet_v2(pretrained=False)
    model.classifier[1] = torch.nn.Linear(model.last_channel, 3)  # 3 classes
    
    # Load the state dictionary
    model.load_state_dict(torch.load(model_path, map_location='cpu'))
    model.eval()
    
    # Create a sample input with the same preprocessing as validation
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    # Create a sample input tensor with the correct dimensions
    sample_input = torch.randn(1, 3, 224, 224)
    
    # Export to ONNX
    torch.onnx.export(model, sample_input, 'temp_model.onnx',
                     input_names=['input'],
                     output_names=['output'],
                     dynamic_axes={'input': {0: 'batch_size'},
                                 'output': {0: 'batch_size'}})
    
    # Convert ONNX to TensorFlow
    import onnx
    from onnx_tf.backend import prepare
    
    onnx_model = onnx.load('temp_model.onnx')
    tf_rep = prepare(onnx_model)
    tf_rep.export_graph('tf_model')
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_saved_model('tf_model')
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    tflite_model = converter.convert()
    
    # Save TFLite model
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Model exported to {output_path}")

if __name__ == '__main__':
    # Use the same path as in train.py for the best model
    convert_to_tflite('models/checkpoints/best_model.pth', 'models/cvi_model.tflite') 