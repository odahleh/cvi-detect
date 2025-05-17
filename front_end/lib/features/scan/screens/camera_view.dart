import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_classifier.dart';
import '../../../models/classification_result.dart';

/// Screen for capturing and analyzing leg images
class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isProcessing = false;
  ClassificationResult? _classificationResult;
  final ImageClassifier _classifier = ImageClassifier();

  @override
  void initState() {
    super.initState();
    // Immediately start the camera when the view loads
    _takePhoto();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _isProcessing = true;
          _classificationResult = null;
        });
        
        // Process the image
        final result = await _classifier.classifyImage(_imageFile);
        
        setState(() {
          _classificationResult = result;
          _isProcessing = false;
        });
      } else {
        // User canceled the camera, go back
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _retake() {
    setState(() {
      _imageFile = null;
      _classificationResult = null;
      _isProcessing = false;
    });
    _takePhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Image display
            if (_imageFile != null)
              Positioned.fill(
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Positioned.fill(
                child: Center(
                  child: Text(
                    'Preparing camera...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            
            // Loading indicator
            if (_isProcessing)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            
            // Classification result overlay
            if (_classificationResult != null && !_isProcessing)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(179), // Approximately 0.7 opacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Result: ${_classificationResult!.severity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _classificationResult!.explainer,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tip: ${_classificationResult!.tip}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Bottom camera button
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _imageFile == null ? null : _retake,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _imageFile == null ? Colors.grey : Colors.yellow,
                    ),
                    child: _imageFile == null 
                        ? null 
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 40,
                            color: Colors.black,
                          ),
                  ),
                ),
              ),
            ),
            
            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 