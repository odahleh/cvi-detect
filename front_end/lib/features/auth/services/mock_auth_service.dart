import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// Mock user data
const _mockUser = UserModel(
  uid: 'mock-user-123',
  displayName: 'Test User',
  email: 'test@example.com',
  photoURL: 'https://ui-avatars.com/api/?name=Test+User&background=random',
);

class MockAuthService {
  // Authentication state controller
  final _authStateController = StreamController<UserModel?>.broadcast();
  
  // Current user
  UserModel? _currentUser;
  
  MockAuthService() {
    // Initialize with no user (signed out)
    // Add a slight delay to simulate async initialization
    Future.microtask(() => _authStateController.add(null));
  }
  
  // Current user stream
  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  
  // Current user
  UserModel? get currentUser => _currentUser;
  
  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Sign in the mock user
    _currentUser = _mockUser;
    _authStateController.add(_currentUser);
    
    return _currentUser;
  }
  
  // Sign out
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Sign out
    _currentUser = null;
    _authStateController.add(null);
  }
  
  // Check if user is signed in
  bool get isSignedIn => _currentUser != null;
  
  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

// Provider for the mock auth service
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  final service = MockAuthService();
  ref.onDispose(() => service.dispose());
  return service;
}); 