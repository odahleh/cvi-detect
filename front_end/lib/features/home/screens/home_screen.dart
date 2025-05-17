import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/leg_stats.dart';
import '../widgets/leg_card_view.dart';
import '../../cvi_detection/screens/capture_screen.dart';
import '../../auth/providers/user_provider.dart';

/// Main home screen showing leg health information
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
  }

  void _signOut() {
    ref.read(authStateNotifierProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider);
    final userName = userModel?.displayName ?? 'User';
    final userPhotoUrl = userModel?.photoURL;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Sign Out
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
                          "Welcome back, $userName",
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // User avatar
                    GestureDetector(
                      onTap: () {
                        _showProfileMenu(context);
                      },
                      child: userPhotoUrl != null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(userPhotoUrl),
                          )
                        : const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
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
  
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 