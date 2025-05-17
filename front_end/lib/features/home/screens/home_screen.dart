import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/leg_stats.dart';
import '../widgets/leg_card_view.dart';
import '../../scan/screens/camera_view.dart';

/// Main home screen showing leg health information
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data for demonstration
  final leftLegIndicators = const LegIndicators(
    bloodPressure: 0.7,
    bpText: "118/78",
    swelling: 0.3,
    swellingText: "Mild",
    temperature: 0.2,
    tempText: "36.8°C",
  );
  
  final rightLegIndicators = const LegIndicators(
    bloodPressure: 0.8,
    bpText: "122/80",
    swelling: 0.6,
    swellingText: "Moderate",
    temperature: 0.4,
    tempText: "37.1°C",
  );
  
  final dailyStats = const LegDailyStats();

  void _showCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CameraView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "VenaCura",
                          style: GoogleFonts.manrope(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Welcome back, Jane",
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Left leg card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LegCardView(
                  legName: "Left leg",
                  onCameraPressed: _showCamera,
                  indicators: leftLegIndicators,
                  dailyStats: dailyStats,
                ),
              ),
              
              // Right leg card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LegCardView(
                  legName: "Right leg",
                  onCameraPressed: _showCamera,
                  indicators: rightLegIndicators,
                  dailyStats: dailyStats,
                ),
              ),
              
              // Bottom padding
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 