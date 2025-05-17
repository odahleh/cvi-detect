import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/user_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App title "VenaCura"
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.1),
                child: Text(
                  'VenaCura',
                  style: GoogleFonts.manrope(
                    textStyle: theme.textTheme.displaySmall,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Legs illustration
              Expanded(
                child: Center(
                  child: _buildLegsIllustration(),
                ),
              ),
              
              // App description text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Continue to track early signs of CVI, monitor leg health, and take action before it gets worse.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Sign up button
              _buildButton(
                context: context,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                text: 'Sign up',
                backgroundColor: const Color(0xFF5B7EDE),
                textColor: Colors.white,
              ),
              
              const SizedBox(height: 16),
              
              // Login button
              _buildButton(
                context: context,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                text: 'Log in',
                backgroundColor: const Color(0xFFB8496C),
                textColor: Colors.white,
              ),
              
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
  
  // Custom button widget
  Widget _buildButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // Legs illustration with veins
  Widget _buildLegsIllustration() {
    return CustomPaint(
      size: const Size(300, 300),
      painter: LegsIllustrationPainter(),
    );
  }
}

// Custom painter for drawing legs with veins
class LegsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint outlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
      
    final Paint blueVeinPaint = Paint()
      ..color = const Color(0xFF5B7EDE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    final Paint redVeinPaint = Paint()
      ..color = const Color(0xFFB8496C)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    // Draw left leg outline
    final Path leftLegPath = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(
        size.width * 0.05, size.height * 0.5,
        size.width * 0.15, size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.2, size.height * 0.9,
        size.width * 0.3, size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.35, size.height * 0.7,
        size.width * 0.35, 0,
      )
      ..close();
      
    // Draw right leg outline
    final Path rightLegPath = Path()
      ..moveTo(size.width * 0.45, 0)
      ..quadraticBezierTo(
        size.width * 0.45, size.height * 0.7,
        size.width * 0.55, size.height * 0.95,
      )
      ..quadraticBezierTo(
        size.width * 0.7, size.height,
        size.width * 0.75, size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.9, size.height * 0.7,
        size.width * 0.65, 0,
      )
      ..close();
      
    // Draw the leg outlines
    canvas.drawPath(leftLegPath, outlinePaint);
    canvas.drawPath(rightLegPath, outlinePaint);
    
    // Draw veins on left leg - upper part
    _drawWavyLine(
      canvas, 
      Offset(size.width * 0.18, size.height * 0.3), 
      Offset(size.width * 0.32, size.height * 0.3),
      blueVeinPaint,
      waveHeight: 4,
      segments: 4
    );
    
    _drawWavyLine(
      canvas, 
      Offset(size.width * 0.2, size.height * 0.32), 
      Offset(size.width * 0.3, size.height * 0.32),
      redVeinPaint,
      waveHeight: 3,
      segments: 3
    );
    
    // Draw veins on right leg - middle part
    _drawWavyLine(
      canvas, 
      Offset(size.width * 0.5, size.height * 0.5), 
      Offset(size.width * 0.65, size.height * 0.5),
      blueVeinPaint,
      waveHeight: 5,
      segments: 4
    );
    
    _drawWavyLine(
      canvas, 
      Offset(size.width * 0.52, size.height * 0.53), 
      Offset(size.width * 0.63, size.height * 0.53),
      redVeinPaint,
      waveHeight: 4,
      segments: 3
    );
    
    // Draw veins on foot area
    _drawWavyLine(
      canvas, 
      Offset(size.width * 0.35, size.height * 0.75), 
      Offset(size.width * 0.5, size.height * 0.75),
      blueVeinPaint,
      waveHeight: 4,
      segments: 4
    );
    
    _drawWavyLine(
      canvas, 
      Offset(size.width * 0.38, size.height * 0.78), 
      Offset(size.width * 0.48, size.height * 0.78),
      redVeinPaint,
      waveHeight: 3,
      segments: 3
    );
  }
  
  // Helper method to draw wavy veins
  void _drawWavyLine(
    Canvas canvas, 
    Offset start, 
    Offset end, 
    Paint paint, 
    {double waveHeight = 5, 
    int segments = 4}
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    final width = end.dx - start.dx;
    final segmentWidth = width / segments;
    
    for (int i = 0; i < segments; i++) {
      final x1 = start.dx + segmentWidth * i;
      final x2 = start.dx + segmentWidth * (i + 1);
      final midX = (x1 + x2) / 2;
      
      final waveY = i % 2 == 0 ? start.dy + waveHeight : start.dy - waveHeight;
      
      path.quadraticBezierTo(midX, waveY, x2, start.dy);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 