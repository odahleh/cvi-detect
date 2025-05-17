import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Circular indicator widget for leg health metrics
class LegStatusCircle extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String label;
  final Color color;
  final String displayText;
  final double fontSize;
  final double circleSize;
  final double lineWidth;

  const LegStatusCircle({
    Key? key,
    required this.value,
    required this.label,
    required this.color,
    required this.displayText,
    this.fontSize = 10,
    this.circleSize = 65,
    this.lineWidth = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: fontSize + 1,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(
          width: circleSize,
          height: circleSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: lineWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withAlpha((color.a * 0.3).round()),
                ),
              ),
              // Foreground circle showing the progress
              CircularProgressIndicator(
                value: value.clamp(0.0, 1.0),
                strokeWidth: lineWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              // Center text
              Text(
                displayText,
                style: GoogleFonts.manrope(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
      ],
    );
  }
} 