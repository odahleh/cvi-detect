import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/cvi_result.dart';
import 'normal_result_screen.dart';
import 'moderate_result_screen.dart';
import 'severe_result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _errorMessage = null;
        });
        
        await _uploadImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to take picture: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://5a2b-18-29-193-192.ngrok-free.app/predict'),
      );
      
      // Add the file to the request
      final file = await http.MultipartFile.fromPath(
        'file',
        _imageFile!.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
      
      // Send the request
      final response = await request.send();
      
      if (response.statusCode == 200) {
        // Parse the response
        final responseString = await response.stream.bytesToString();
        final result = CVIResult.fromResponseBody(responseString);
        
        if (!mounted) return;
        
        // Navigate to the appropriate result screen based on the severity
        switch (result.severity) {
          case CVISeverity.normal:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NormalResultScreen(result: result)),
            );
            break;
          case CVISeverity.moderate:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ModerateResultScreen(result: result)),
            );
            break;
          case CVISeverity.severe:
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SevereResultScreen(result: result)),
            );
            break;
        }
      } else {
        // Handle error
        final responseString = await response.stream.bytesToString();
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}\n$responseString';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload image: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('VenaCura CVI Detection'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Take a photo of your lower leg',
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Position your camera to capture a clear view of your lower leg',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Camera button inspired by the iOS UI
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _imageFile == null ? Colors.white : Colors.yellow,
                        border: Border.all(color: Colors.black12, width: 3),
                      ),
                      child: Icon(
                        _imageFile == null ? Icons.camera_alt : Icons.refresh_rounded,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Analyzing image...'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 