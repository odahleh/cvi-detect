import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import models, transforms
from torch.utils.data import Dataset, DataLoader
from PIL import Image
import os
from tqdm import tqdm
import matplotlib.pyplot as plt

# Check for MPS availability
device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")

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
        
        # Load images and labels
        for class_folder in os.listdir(data_dir):
            if class_folder in self.class_mapping and class_folder.isdigit():
                class_dir = os.path.join(data_dir, class_folder)
                if os.path.isdir(class_dir):
                    for img_name in os.listdir(class_dir):
                        if img_name.endswith('.bmp'):
                            self.images.append(os.path.join(class_dir, img_name))
                            self.labels.append(self.class_mapping[class_folder])
        
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
            
        return image, label

def train_model(model, train_loader, criterion, optimizer, num_epochs=20):
    model.train()
    best_acc = 0.0
    
    for epoch in range(num_epochs):
        running_loss = 0.0
        correct = 0
        total = 0
        
        pbar = tqdm(train_loader, desc=f'Epoch {epoch+1}/{num_epochs}')
        for images, labels in pbar:
            images, labels = images.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item()
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()
            
            pbar.set_postfix({'loss': running_loss/total, 'acc': 100.*correct/total})
        
        epoch_acc = 100.*correct/total
        print(f'Epoch {epoch+1} - Loss: {running_loss/len(train_loader):.4f}, '
              f'Accuracy: {epoch_acc:.2f}%')
        
        # Save best model
        if epoch_acc > best_acc:
            best_acc = epoch_acc
            torch.save(model.state_dict(), 'models/checkpoints/best_model.pth')
            print(f'New best model saved with accuracy: {best_acc:.2f}%')

def main():
    # Data transforms
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ColorJitter(brightness=0.2, contrast=0.2),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    # Create dataset and dataloader
    dataset = CVIDataset('data/CVI-img-datasets-2/imagedata', transform=transform)
    train_loader = DataLoader(dataset, batch_size=32, shuffle=True, num_workers=4)
    
    # Load pretrained MobileNetV2
    model = models.mobilenet_v2(pretrained=True)
    model.classifier[1] = nn.Linear(model.last_channel, 3)  # 3 classes
    model = model.to(device)
    
    # Loss and optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    # Train
    train_model(model, train_loader, criterion, optimizer)
    
    # Save final model
    torch.save(model.state_dict(), 'models/checkpoints/final_model.pth')

if __name__ == '__main__':
    main() 