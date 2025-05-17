import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/leg_stats.dart';
import 'leg_status_circle.dart';

/// Card widget displaying leg health information
class LegCardView extends StatelessWidget {
  final String legName;
  final Function() onCameraPressed;
  final LegIndicators indicators;
  final LegDailyStats dailyStats;

  const LegCardView({
    Key? key,
    required this.legName,
    required this.onCameraPressed,
    required this.indicators,
    required this.dailyStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(30), // Approximately 0.12 opacity
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            legName,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          
          // First row: Status circles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LegStatusCircle(
                  value: indicators.bloodPressure,
                  label: "Blood pressure",
                  color: Colors.green,
                  displayText: indicators.bpText,
                ),
                LegStatusCircle(
                  value: indicators.swelling,
                  label: "Swelling",
                  color: Colors.red,
                  displayText: indicators.swellingText,
                ),
                LegStatusCircle(
                  value: indicators.temperature,
                  label: "Temperature",
                  color: Colors.yellow,
                  displayText: indicators.tempText,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 5),
          
          // Second row: Camera button and stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Camera button
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onCameraPressed,
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "Upload Photo",
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Daily stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Stats",
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Sedentary: ${dailyStats.sedentaryHours}",
                      style: _statTextStyle(),
                    ),
                    Text(
                      "Elevation: ${dailyStats.legElevation}",
                      style: _statTextStyle(),
                    ),
                    Text(
                      "Standing: ${dailyStats.standingTime}",
                      style: _statTextStyle(),
                    ),
                    Text(
                      "Pain Level: ${dailyStats.painLevel}",
                      style: _statTextStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  TextStyle _statTextStyle() {
    return GoogleFonts.manrope(
      fontSize: 11,
      color: Colors.black54,
    );
  }
} 