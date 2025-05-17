import torch
import torch.nn as nn
from torchvision import models, transforms
from torch.utils.data import Dataset, DataLoader, random_split
from PIL import Image
import os
import random
import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm
# from dataset import CVIDataset
from segment_leg import segment_leg  # Import the segmentation function

# Set random seed for reproducibility
random.seed(42)
torch.manual_seed(42)
if torch.cuda.is_available():
    torch.cuda.manual_seed(42)
np.random.seed(42)

# Check for MPS availability
device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
print(f"Using device: {device}")

class CVIDataset(Dataset):
    def __init__(self, data_dir, transform=None):
        self.data_dir = data_dir
        self.transform = transform
        self.classes = ['normal', 'moderate', 'severe']
        self.class_mapping = {
            '1': 0,  # normal (C0)
            '2': 0,  # normal (C1)
            '3': 1,  # moderate (C2, C3)
            '4': 2,  # severe (C4)
            '5': 2   # severe (C5, C6)
        }
        
        self.images = []
        self.labels = []
        self.image_paths = []  # Store original paths for visualization
        
        # Load images and labels
        for class_folder in os.listdir(data_dir):
            if class_folder in self.class_mapping and class_folder.isdigit():
                class_dir = os.path.join(data_dir, class_folder)
                if os.path.isdir(class_dir):
                    for img_name in os.listdir(class_dir):
                        if img_name.endswith('.bmp'):
                            img_path = os.path.join(class_dir, img_name)
                            self.images.append(img_path)
                            self.labels.append(self.class_mapping[class_folder])
                            self.image_paths.append(img_path)
        
        print(f"Found {len(self.images)} images across {len(self.classes)} classes")
        for i, class_name in enumerate(self.classes):
            class_count = sum(1 for label in self.labels if label == i)
            print(f"Class {class_name}: {class_count} images")
    
    def __len__(self):
        return len(self.images)
    
    def __getitem__(self, idx):
        img_path = self.images[idx]
        label = self.labels[idx]
        
        image = Image.open(img_path).convert('RGB')
        if self.transform:
            image = self.transform(image)
            
        return image, label, self.image_paths[idx]

def evaluate_model(model, test_loader):
    model.eval()
    correct = 0
    total = 0
    all_preds = []
    all_labels = []
    all_images = []
    all_paths = []
    
    with torch.no_grad():
        for images, labels, paths in tqdm(test_loader, desc="Evaluating"):
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            _, predicted = outputs.max(1)
            
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()
            
            # Store predictions, actual labels, and images
            all_preds.extend(predicted.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            all_images.extend(images.cpu().numpy())
            all_paths.extend(paths)
    
    accuracy = 100.0 * correct / total
    print(f'Test Accuracy: {accuracy:.2f}%')
    
    return np.array(all_images), np.array(all_preds), np.array(all_labels), all_paths

def visualize_predictions(images, predictions, true_labels, class_names, image_paths, num_samples=10):
    """Visualize model predictions vs. ground truth"""
    # Choose random samples from test set
    indices = np.random.choice(range(len(images)), min(num_samples, len(images)), replace=False)
    
    plt.figure(figsize=(15, 10))
    for i, idx in enumerate(indices):
        img = images[idx].transpose(1, 2, 0)  # Convert from CxHxW to HxWxC
        # Undo normalization
        img = img * np.array([0.229, 0.224, 0.225]) + np.array([0.485, 0.456, 0.406])
        img = np.clip(img, 0, 1)
        
        pred = predictions[idx]
        true = true_labels[idx]
        path = image_paths[idx]
        
        plt.subplot(2, 5, i + 1)
        plt.imshow(img)
        color = 'green' if pred == true else 'red'
        plt.title(f"Pred: {class_names[pred]}\nTrue: {class_names[true]}", 
                 color=color)
        plt.axis('off')
    
    plt.tight_layout()
    plt.savefig('models/prediction_visualization.png')
    print(f"Visualization saved to 'models/prediction_visualization.png'")
    
    # Create confusion matrix
    cm = np.zeros((len(class_names), len(class_names)), dtype=int)
    for true, pred in zip(true_labels, predictions):
        cm[true][pred] += 1
    
    plt.figure(figsize=(10, 8))
    plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title('Confusion Matrix')
    plt.colorbar()
    tick_marks = np.arange(len(class_names))
    plt.xticks(tick_marks, class_names, rotation=45)
    plt.yticks(tick_marks, class_names)
    
    # Add text annotations
    thresh = cm.max() / 2.
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            plt.text(j, i, format(cm[i, j], 'd'),
                    horizontalalignment="center",
                    color="white" if cm[i, j] > thresh else "black")
    
    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')
    plt.savefig('models/confusion_matrix.png')
    print(f"Confusion matrix saved to 'models/confusion_matrix.png'")
    
    # Create a detailed report for misclassified images
    misclassified = [(path, true, pred) for path, true, pred in zip(image_paths, true_labels, predictions) if true != pred]
    if misclassified:
        with open('models/misclassified_report.txt', 'w') as f:
            f.write("MISCLASSIFIED IMAGES REPORT\n")
            f.write("==========================\n\n")
            for path, true, pred in misclassified:
                f.write(f"Image: {path}\n")
                f.write(f"True class: {class_names[true]}\n")
                f.write(f"Predicted class: {class_names[pred]}\n")
                f.write("-" * 50 + "\n")
        print(f"Misclassified report saved to 'models/misclassified_report.txt'")

def predict_single_image(model, image_path, class_names, transform):
    """Run inference on a single image and visualize the result"""
    # Segment the leg first
    segmented_dir = os.path.dirname(image_path)
    segmented_filename = f"{os.path.splitext(os.path.basename(image_path))[0]}_segmented.jpg"
    segmented_path = os.path.join(segmented_dir, segmented_filename)
    
    # Segment the leg
    try:
        segmented_image = segment_leg(image_path, segmented_path)
        print(f"Segmented image saved to {segmented_path}")
        # Use the segmented image for inference
        image_for_inference = segmented_image
    except Exception as e:
        print(f"Segmentation failed: {e}. Using original image.")
        image_for_inference = Image.open(image_path).convert('RGB')
    
    # Preprocess the image
    input_tensor = transform(image_for_inference).unsqueeze(0).to(device)
    
    # Run inference
    model.eval()
    with torch.no_grad():
        output = model(input_tensor)
        probabilities = torch.nn.functional.softmax(output, dim=1)[0]
        _, predicted_class = output.max(1)
    
    # Convert to numpy for visualization
    probs = probabilities.cpu().numpy()
    pred_class = predicted_class.item()
    
    # Visualize
    plt.figure(figsize=(15, 6))
    
    # Display original image
    plt.subplot(1, 3, 1)
    orig_img = np.array(Image.open(image_path).convert('RGB'))
    plt.imshow(orig_img)
    plt.title("Original Image")
    plt.axis('off')
    
    # Display segmented image
    plt.subplot(1, 3, 2)
    seg_img = np.array(image_for_inference)
    plt.imshow(seg_img)
    plt.title(f"Segmented Image\nPrediction: {class_names[pred_class]}")
    plt.axis('off')
    
    # Display probability bar chart
    plt.subplot(1, 3, 3)
    bars = plt.bar(range(len(class_names)), probs)
    plt.xticks(range(len(class_names)), class_names, rotation=45)
    plt.xlabel('Class')
    plt.ylabel('Probability')
    plt.title('Class Probabilities')
    
    # Highlight the predicted class
    bars[pred_class].set_color('red')
    
    plt.tight_layout()
    plt.savefig('models/single_image_prediction.png')
    print(f"Single image prediction saved to 'models/single_image_prediction.png'")
    
    # Print prediction details
    print(f"\nPrediction for {image_path}:")
    print(f"Predicted class: {class_names[pred_class]}")
    for i, class_name in enumerate(class_names):
        print(f"{class_name}: {probs[i]*100:.2f}%")

def main():
    # Data transforms (match the validation transforms from training)
    test_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    # Create dataset
    dataset = CVIDataset('data/CVI-img-datasets-2/imagedata', transform=test_transform)
    
    # Create test loader
    test_loader = DataLoader(dataset, batch_size=32, shuffle=False, num_workers=4)
    
    # Load pre-trained model
    model = models.mobilenet_v2(pretrained=False)
    model.classifier[1] = nn.Linear(model.last_channel, 3)  # 3 classes
    
    # Load checkpoint
    checkpoint_path = 'models/checkpoints/best_model.pth'
    if os.path.exists(checkpoint_path):
        model.load_state_dict(torch.load(checkpoint_path, map_location=device))
        print(f"Loaded model checkpoint from {checkpoint_path}")
    else:
        print(f"Error: Checkpoint not found at {checkpoint_path}")
        return
    
    model = model.to(device)
    
    # Evaluate and visualize
    # images, predictions, true_labels, image_paths = evaluate_model(model, test_loader)
    # visualize_predictions(images, predictions, true_labels, dataset.classes, image_paths)
    
    # Run inference on a single test image
    test_img_path = 'models/test_img.jpg'
    if os.path.exists(test_img_path):
        predict_single_image(model, test_img_path, dataset.classes, test_transform)
    else:
        print(f"Error: Test image not found at {test_img_path}")

if __name__ == '__main__':
    main() 