import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_classifier.dart';
import '../../../models/classification_result.dart';
import '../../../features/cvi_detection/screens/normal_result_screen.dart';
import '../../../features/cvi_detection/screens/moderate_result_screen.dart';
import '../../../features/cvi_detection/screens/severe_result_screen.dart';
import '../../../features/cvi_detection/models/cvi_result.dart';

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
  bool _isSimulator = false;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Don't automatically launch camera on initialization
    // Instead, wait for explicit user action
    _checkSimulator();
  }
  
  Future<void> _checkSimulator() async {
    // Simple check for simulator - not opening camera automatically
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      setState(() {
        // We'll assume it's not a simulator for now
        _isSimulator = false;
        _cameraInitialized = true;
      });
    } else {
      setState(() {
        _isSimulator = false;
        _cameraInitialized = true;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    
    try {
      setState(() {
        _isProcessing = true;
      });
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _classificationResult = null;
        });
        
        // Process the image
        final result = await _classifier.classifyImage(_imageFile);
        
        if (!mounted) return;
        
        // Update UI to not processing
        setState(() {
          _isProcessing = false;
          _classificationResult = result;
        });
        
        // Navigate to result screen if we have a result
        if (result != null) {
          await Future.delayed(Duration.zero); // Ensure state is updated before navigation
          _navigateToResultScreen(result);
        }
      } else {
        // User canceled gallery picker
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint("Gallery error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_isProcessing) return;
    
    try {
      // Show loading state while accessing camera
      setState(() {
        _isProcessing = true;
      });
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
      );
      
      if (image != null) {
        if (!mounted) return;
        setState(() {
          _imageFile = File(image.path);
          _classificationResult = null;
        });
        
        // Process the image
        final result = await _classifier.classifyImage(_imageFile);
        
        if (!mounted) return;
        
        // Update UI to not processing
        setState(() {
          _isProcessing = false;
          _classificationResult = result;
        });
        
        // Navigate to result screen if we have a result
        if (result != null) {
          await Future.delayed(Duration.zero); // Ensure state is updated before navigation
          _navigateToResultScreen(result);
        }
      } else {
        // User canceled the camera
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      
      // Show error and option to use gallery instead
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Camera Error'),
          content: Text('Could not access camera: ${e.toString()}\n\nWould you like to select an image from gallery instead?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickFromGallery();
              },
              child: const Text('Use Gallery'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToResultScreen(ClassificationResult result) {
    // Make probabilities more realistic by distributing values
    Map<String, double> probabilities = {
      'normal': 0.1,
      'moderate': 0.1,
      'severe': 0.1,
    };
    
    // Set the detected severity to have the highest probability
    String severityKey = result.severity.toLowerCase();
    probabilities[severityKey] = result.confidence;
    
    // Adjust other probabilities to ensure sum is close to 1.0
    double remainingProb = 1.0 - result.confidence;
    double distributedProb = remainingProb / 2;
    
    for (String key in probabilities.keys) {
      if (key != severityKey) {
        probabilities[key] = distributedProb;
      }
    }
    
    // Create a CVIResult
    final cviResult = CVIResult(
      filename: _imageFile?.path.split('/').last ?? 'scan.jpg',
      severity: _getSeverityEnum(result.severity),
      probabilities: probabilities,
    );
    
    // Navigate to the appropriate result screen
    Widget destinationScreen;
    
    switch (result.severity.toLowerCase()) {
      case 'normal':
        destinationScreen = NormalResultScreen(result: cviResult);
        break;
      case 'moderate':
        destinationScreen = ModerateResultScreen(result: cviResult);
        break;
      case 'severe':
        destinationScreen = SevereResultScreen(result: cviResult);
        break;
      default:
        // Default to moderate if unknown
        destinationScreen = ModerateResultScreen(result: cviResult);
    }
    
    // Use pushReplacement to replace the camera screen with the result screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }
  
  CVISeverity _getSeverityEnum(String severityString) {
    switch (severityString.toLowerCase()) {
      case 'normal':
        return CVISeverity.normal;
      case 'moderate':
        return CVISeverity.moderate;
      case 'severe':
        return CVISeverity.severe;
      default:
        return CVISeverity.normal;
    }
  }

  void _retake() {
    setState(() {
      _imageFile = null;
      _classificationResult = null;
      _isProcessing = false;
    });
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
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isProcessing ? 'Processing...' : 'Tap the button below to take a picture',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
            
            // Bottom buttons
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  GestureDetector(
                    onTap: _isProcessing ? null : _pickFromGallery,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Camera button
                  GestureDetector(
                    onTap: _isProcessing ? null : (_imageFile == null ? _takePhoto : _retake),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _imageFile == null ? Colors.white : Colors.yellow,
                      ),
                      child: Icon(
                        _imageFile == null ? Icons.camera_alt : Icons.refresh_rounded,
                        size: 40,
                        color: _imageFile == null ? Colors.black : Colors.black,
                      ),
                    ),
                  ),
                  
                  // Placeholder for symmetry
                  const SizedBox(width: 60, height: 60),
                ],
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