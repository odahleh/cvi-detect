import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../upload_controller.dart';
import 'result_screen.dart';

/// Screen for uploading images for CVI detection
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('VenaCura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Sign out using auth controller
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildImagePreview(theme),
              const SizedBox(height: 24),
              _buildImagePickerButtons(),
              const Spacer(),
              _buildAnalyzeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the screen header
  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Photo',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Take a photo or select an image from your gallery to analyze for signs of Chronic Venous Insufficiency.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  /// Build the image preview area
  Widget _buildImagePreview(ThemeData theme) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No image selected',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// Build image picker buttons (camera and gallery)
  Widget _buildImagePickerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPickerButton(
          icon: Icons.camera_alt,
          label: 'Camera',
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        _buildPickerButton(
          icon: Icons.photo_library,
          label: 'Gallery',
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  /// Build individual picker button
  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  /// Build the analyze button
  Widget _buildAnalyzeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _selectedImage == null || _isUploading
          ? null
          : () => _analyzeImage(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isUploading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Analyzing...'),
              ],
            )
          : const Text('Analyze Image'),
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Analyze the selected image
  Future<void> _analyzeImage(BuildContext context) async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final controller = ref.read(uploadControllerProvider.notifier);
      await controller.uploadImage(_selectedImage!);
      
      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ResultScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
} 