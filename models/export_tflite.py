import torch
import tensorflow as tf
import numpy as np
from train import CVIDataset, transform

def convert_to_tflite(model_path, output_path):
    # Load PyTorch model
    model = torch.load(model_path, map_location='cpu')
    model.eval()
    
    # Create a sample input
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
    convert_to_tflite('models/checkpoints/cvi_model.pth', 'models/cvi_model.tflite') 