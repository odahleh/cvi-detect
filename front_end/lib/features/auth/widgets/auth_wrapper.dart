import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../providers/user_provider.dart';
import '../screens/login_screen.dart';
import '../../home/screens/home_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _timeoutOccurred = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Set a timeout to prevent infinite loading
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _timeoutOccurred = true;
      });
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    // If timeout occurred, show login screen
    if (_timeoutOccurred && authState is AsyncLoading) {
      return const LoginScreen();
    }
    
    return authState.when(
      data: (user) {
        // Cancel timeout timer since we got data
        _timeoutTimer?.cancel();
        
        // If the user is authenticated, show the home screen
        if (user != null) {
          return const HomeScreen();
        }
        // Otherwise, show the login screen
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(authStateProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 