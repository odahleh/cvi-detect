import 'package:flutter/material.dart';

// A simplified Auth Gate that shows a demo home screen
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For demo purposes, we'll just show a home screen
    return const DemoHomeScreen();
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VenaCura Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'CVI Detection App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload an image to detect Chronic Venous Insufficiency',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image upload feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gallery picker feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 