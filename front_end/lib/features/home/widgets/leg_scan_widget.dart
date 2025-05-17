import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/cvi_detection/screens/capture_screen.dart';

class LegScanWidget extends StatelessWidget {
  final Function(String result) onScanComplete;

  const LegScanWidget({
    Key? key,
    required this.onScanComplete,
  }) : super(key: key);

  void _navigateToCaptureScreen(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
    
    // Check if a result was returned and pass it to the callback
    if (result != null && result is String) {
      onScanComplete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: const Icon(
          Icons.camera_alt,
          size: 36,
          color: Colors.blue,
        ),
        title: Text(
          "Leg AI Scan",
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Scan your leg to detect CVI severity",
            style: GoogleFonts.manrope(
              fontSize: 14,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _navigateToCaptureScreen(context),
      ),
    );
  }
} 