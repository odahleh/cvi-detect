import cv2
import numpy as np
from PIL import Image
import os
import matplotlib.pyplot as plt

def segment_leg(image_path, output_path=None, visualize_seeds=True):
    """
    Leg segmentation using multiple seed points for flood fill to preserve CVI symptoms.
    
    Args:
        image_path: Path to the input image
        output_path: Path to save the processed image (if None, returns the image without saving)
        visualize_seeds: Whether to visualize and save the seed points
        
    Returns:
        PIL Image object with the processed leg
    """
    # Read the image
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"Could not read image at {image_path}")
    
    # Convert to RGB for processing and display
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Create a copy for flood filling
    h, w = img.shape[:2]
    
    # Convert to HSV for better skin detection
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    # Define a range for typical skin color in HSV
    # These values cover a range of light skin tones
    lower_skin = np.array([0, 20, 70], dtype=np.uint8)
    upper_skin = np.array([20, 150, 255], dtype=np.uint8)
    
    # Create a binary mask for skin color
    skin_mask = cv2.inRange(img_hsv, lower_skin, upper_skin)
    
    # Apply morphological operations to clean up the mask
    kernel = np.ones((5, 5), np.uint8)
    skin_mask = cv2.morphologyEx(skin_mask, cv2.MORPH_OPEN, kernel)
    skin_mask = cv2.morphologyEx(skin_mask, cv2.MORPH_CLOSE, kernel)
    
    # Create a copy of the image for flood fill
    flood_img = np.zeros_like(img)
    
    # Create a mask for flood fill
    ff_mask = np.zeros((h+2, w+2), np.uint8)
    
    # Define flood fill parameters
    flood_fill_flags = 4  # 4-connected neighborhood
    flood_fill_flags |= cv2.FLOODFILL_FIXED_RANGE
    flood_fill_flags |= (255 << 8)  # Fill with white
    
    # Find all skin pixels to use as seed points
    y_indices, x_indices = np.where(skin_mask > 0)
    
    # If no skin pixels found, use fallback method
    if len(y_indices) == 0:
        print("No skin pixels detected, using fallback method")
        return background_flood_fill(img, output_path)
    
    # Sample seed points (use a subset to avoid too many flood fills)
    num_seeds = min(50, len(y_indices))
    step = len(y_indices) // num_seeds
    
    print(f"Using {num_seeds} seed points for flood fill")
    
    # Create a copy of the original image to visualize seed points
    seed_visualization = img_rgb.copy()
    seed_points = []
    
    # Use each seed point for flood fill
    for i in range(0, len(y_indices), step):
        if i >= len(y_indices):
            break
            
        y, x = y_indices[i], x_indices[i]
        seed_points.append((x, y))
        
        # Skip if this pixel has already been filled
        if flood_img[y, x, 0] == 255:
            continue
            
        # Get the color at this seed point
        seed_color = img[y, x].tolist()
        
        # Create a temporary image for this flood fill
        temp_img = img.copy()
        
        # Flood fill from this seed point
        cv2.floodFill(temp_img, ff_mask.copy(), (x, y), (255, 255, 255), 
                     (15, 15, 15), (15, 15, 15), flood_fill_flags)
        
        # Convert to grayscale
        temp_gray = cv2.cvtColor(temp_img, cv2.COLOR_BGR2GRAY)
        
        # Threshold to get binary mask
        _, temp_mask = cv2.threshold(temp_gray, 254, 255, cv2.THRESH_BINARY)
        
        # Add this flood fill result to the combined result
        flood_img = cv2.bitwise_or(flood_img, cv2.cvtColor(temp_mask, cv2.COLOR_GRAY2BGR))
    
    # Visualize seed points if requested
    if visualize_seeds:
        # Draw seed points on the image
        for x, y in seed_points:
            cv2.circle(seed_visualization, (x, y), 3, (255, 0, 0), -1)
        
        # Save the seed point visualization
        seed_vis_path = os.path.join(os.path.dirname(image_path), 
                                    f"{os.path.splitext(os.path.basename(image_path))[0]}_seeds.jpg")
        Image.fromarray(seed_visualization).save(seed_vis_path)
        print(f"Seed point visualization saved to {seed_vis_path}")
        
        # Also create a visualization of the skin mask
        skin_mask_vis_path = os.path.join(os.path.dirname(image_path), 
                                         f"{os.path.splitext(os.path.basename(image_path))[0]}_skin_mask.jpg")
        Image.fromarray(skin_mask).save(skin_mask_vis_path)
        print(f"Skin mask visualization saved to {skin_mask_vis_path}")
    
    # Convert combined flood fill result to grayscale
    flood_gray = cv2.cvtColor(flood_img, cv2.COLOR_BGR2GRAY)
    
    # Find contours in the combined mask
    contours, _ = cv2.findContours(flood_gray, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # If no significant contours found, try a different approach
    if not contours or max(cv2.contourArea(c) for c in contours) < (h*w*0.05):
        print("Multi-seed flood fill didn't work well, trying background flood fill")
        return background_flood_fill(img, output_path)
    
    # Find the largest contour (the leg)
    largest_contour = max(contours, key=cv2.contourArea)
    
    # Create a clean mask with just the largest contour
    clean_mask = np.zeros_like(flood_gray)
    cv2.drawContours(clean_mask, [largest_contour], 0, 255, -1)
    
    # Save the clean mask from flood fill for visualization
    flood_fill_mask = clean_mask.copy()
    
    # Create a convex hull of the largest contour
    hull = cv2.convexHull(largest_contour)
    
    # Create a mask with the convex hull
    convex_mask = np.zeros_like(flood_gray)
    cv2.drawContours(convex_mask, [hull], 0, 255, -1)
    
    # Use a more conservative approach: dilate the flood fill mask slightly
    # This will fill small gaps but preserve the overall shape better than a full convex hull
    dilated_mask = cv2.dilate(clean_mask, kernel, iterations=3)
    
    # Smooth the edges of the mask
    # First apply a Gaussian blur to smooth the edges
    dilated_mask = cv2.GaussianBlur(dilated_mask, (9, 9), 0)
    
    # Then threshold it back to a binary mask
    _, dilated_mask = cv2.threshold(dilated_mask, 127, 255, cv2.THRESH_BINARY)
    
    # Final mask is the dilated and smoothed version
    final_mask = dilated_mask
    
    # Apply the mask to the original image
    result = cv2.bitwise_and(img_rgb, img_rgb, mask=final_mask)
    
    # Create a black background (instead of white)
    black_bg = np.zeros_like(img_rgb)
    
    # Combine the segmented leg with the black background
    inv_mask = cv2.bitwise_not(final_mask)
    background = cv2.bitwise_and(black_bg, black_bg, mask=inv_mask)
    final_result = cv2.add(result, background)
    
    # If visualize_seeds is True, create a comprehensive visualization
    if visualize_seeds:
        # Create a figure with multiple subplots
        plt.figure(figsize=(15, 10))
        
        # Original image
        plt.subplot(2, 3, 1)
        plt.imshow(img_rgb)
        plt.title('Original Image')
        plt.axis('off')
        
        # Skin mask
        plt.subplot(2, 3, 2)
        plt.imshow(skin_mask, cmap='gray')
        plt.title('Skin Mask')
        plt.axis('off')
        
        # Seed points
        plt.subplot(2, 3, 3)
        plt.imshow(seed_visualization)
        plt.title(f'Seed Points ({len(seed_points)})')
        plt.axis('off')
        
        # Flood fill result
        plt.subplot(2, 3, 4)
        plt.imshow(flood_fill_mask, cmap='gray')
        plt.title('Flood Fill Result')
        plt.axis('off')
        
        # Convex hull mask
        plt.subplot(2, 3, 5)
        plt.imshow(convex_mask, cmap='gray')
        plt.title('Convex Hull')
        plt.axis('off')
        
        # Final result
        plt.subplot(2, 3, 6)
        plt.imshow(final_result)
        plt.title('Final Result')
        plt.axis('off')
        
        # Save the comprehensive visualization
        vis_path = os.path.join(os.path.dirname(image_path), 
                               f"{os.path.splitext(os.path.basename(image_path))[0]}_visualization.jpg")
        plt.tight_layout()
        plt.savefig(vis_path)
        plt.close()
        print(f"Comprehensive visualization saved to {vis_path}")
    
    # Convert to PIL Image
    pil_image = Image.fromarray(final_result)
    
    # Save if output path is provided
    if output_path:
        pil_image.save(output_path)
        print(f"Processed image saved to {output_path}")
    
    return pil_image

def background_flood_fill(img, output_path=None):
    """Alternative approach using background flood fill"""
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    h, w = img.shape[:2]
    
    # Create a mask slightly larger than the image
    mask = np.zeros((h+2, w+2), np.uint8)
    
    # Create a copy of the image for flood fill
    flood_img = img.copy()
    
    # Define flood fill parameters
    flood_fill_flags = 4  # 4-connected neighborhood
    flood_fill_flags |= cv2.FLOODFILL_FIXED_RANGE
    flood_fill_flags |= (255 << 8)  # Fill with white
    
    # Flood fill from the corners to mark the background
    for pt in [(0, 0), (0, h-1), (w-1, 0), (w-1, h-1)]:
        cv2.floodFill(flood_img, mask, pt, (0, 0, 0), (10, 10, 10), (10, 10, 10), flood_fill_flags)
    
    # Convert to grayscale
    flood_gray = cv2.cvtColor(flood_img, cv2.COLOR_BGR2GRAY)
    
    # Threshold to get a binary mask of the leg
    _, leg_mask = cv2.threshold(flood_gray, 1, 255, cv2.THRESH_BINARY)
    
    # Apply morphological operations to clean up the mask
    kernel = np.ones((5, 5), np.uint8)
    leg_mask = cv2.morphologyEx(leg_mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    leg_mask = cv2.morphologyEx(leg_mask, cv2.MORPH_OPEN, kernel)
    
    # Find contours in the mask
    contours, _ = cv2.findContours(leg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # If no significant contours found, use bounding box approach
    if not contours or max(cv2.contourArea(c) for c in contours) < (h*w*0.1):
        print("Background flood fill didn't work well, using bounding box approach")
        return bounding_box_segment(img_rgb, output_path)
    
    # Find the largest contour (the leg)
    largest_contour = max(contours, key=cv2.contourArea)
    
    # Create a clean mask with just the largest contour
    clean_mask = np.zeros_like(leg_mask)
    cv2.drawContours(clean_mask, [largest_contour], 0, 255, -1)
    
    # Apply the mask to the original image
    result = cv2.bitwise_and(img_rgb, img_rgb, mask=clean_mask)
    
    # Create a white background
    white_bg = np.ones_like(img_rgb) * 255
    
    # Combine the segmented leg with the white background
    inv_mask = cv2.bitwise_not(clean_mask)
    background = cv2.bitwise_and(white_bg, white_bg, mask=inv_mask)
    final_result = cv2.add(result, background)
    
    # Convert to PIL Image
    pil_image = Image.fromarray(final_result)
    
    # Save if output path is provided
    if output_path:
        pil_image.save(output_path)
        print(f"Processed image saved to {output_path}")
    
    return pil_image

def bounding_box_segment(img_rgb, output_path=None):
    """Fallback method using bounding box approach"""
    # Convert to grayscale
    gray = cv2.cvtColor(cv2.cvtColor(img_rgb, cv2.COLOR_RGB2BGR), cv2.COLOR_BGR2GRAY)
    
    # Apply Gaussian blur
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # Use Otsu's thresholding
    _, thresh = cv2.threshold(blurred, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # Find contours
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if not contours:
        print("No contours detected, returning original image")
        result = Image.fromarray(img_rgb)
        if output_path:
            result.save(output_path)
        return result
    
    # Find the largest contour
    largest_contour = max(contours, key=cv2.contourArea)
    
    # Get bounding rectangle
    x, y, w, h = cv2.boundingRect(largest_contour)
    
    # Add padding
    padding = 10
    x = max(0, x - padding)
    y = max(0, y - padding)
    w = min(img_rgb.shape[1] - x, w + 2*padding)
    h = min(img_rgb.shape[0] - y, h + 2*padding)
    
    # Crop the image
    cropped = img_rgb[y:y+h, x:x+w]
    
    # Convert to PIL Image
    pil_image = Image.fromarray(cropped)
    
    # Save if output path is provided
    if output_path:
        pil_image.save(output_path)
        print(f"Processed image saved to {output_path}")
    
    return pil_image

def segment_and_save(input_path, output_path):
    """Process a leg image and save the result"""
    try:
        segment_leg(input_path, output_path)
        return True
    except Exception as e:
        print(f"Error processing image {input_path}: {e}")
        return False

if __name__ == "__main__":
    # Test the processing on a sample image
    test_img = "models/test_img.jpg"
    if os.path.exists(test_img):
        segment_and_save(test_img, "models/test_img_segmented.jpg")
    else:
        print(f"Test image not found at {test_img}") 