# CVI Detection Flask API

This Flask application provides an API endpoint to perform Chronic Venous Insufficiency (CVI) detection on an uploaded image.

## Prerequisites

- Python 3.x
- PyTorch
- Torchvision
- Flask
- Pillow
- NumPy

## Setup

1.  **Clone the repository (if you haven't already).**

2.  **Navigate to the `flask_api` directory:**
    ```bash
    cd flask_api
    ```

3.  **Create and activate a virtual environment (recommended):**
    ```bash
    python3 -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

4.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

5.  **Ensure `segment_leg.py` is present:**
    - Copy your `segment_leg.py` file into the `flask_api` directory.
    - Alternatively, create a symbolic link from the original location to the `flask_api` directory. For example, if `segment_leg.py` is in the parent `models` directory:
      ```bash
      # From within the flask_api directory
      ln -s ../models/segment_leg.py segment_leg.py
      ```

6.  **Ensure the model checkpoint is accessible:**
    - The application expects the model checkpoint at `../models/checkpoints/best_model.pth` (relative to the `flask_api` directory).
    - If your main `models` directory (containing `checkpoints` and `segment_leg.py`) is not directly one level above `flask_api`, you might need to adjust the `MODEL_CHECKPOINT_PATH` in `app.py` or create appropriate symbolic links for the `models` directory itself.
    - Example: If your structure is `cvi-detect/models/...` and `cvi-detect/flask_api/...`, the path `../models/...` should work.

## Running the API

1.  **Ensure your model (`best_model.pth`) is in the correct location (`../models/checkpoints/`).**

2.  **Run the Flask application:**
    ```bash
    python app.py
    ```
    The API will start, usually on `http://0.0.0.0:5001`.

## API Endpoint

### `POST /predict`

Accepts a multipart/form-data request with an image file.

-   **Parameter:** `file` (file part containing the image)

-   **Success Response (200 OK):**
    ```json
    {
        "filename": "your_image.jpg",
        "probabilities": {
            "normal": 0.1,
            "moderate": 0.8,
            "severe": 0.1
        },
        "predicted_class_index": 1,
        "predicted_class_name": "moderate"
    }
    ```

-   **Error Responses:**
    -   `400 Bad Request`: If no file is provided or the file part is missing.
    -   `500 Internal Server Error`: If the model is not loaded or an error occurs during processing.

## Example Usage (using cURL)

```bash
curl -X POST -F "file=@/path/to/your/image.jpg" http://localhost:5001/predict
```

Replace `/path/to/your/image.jpg` with the actual path to an image file. 