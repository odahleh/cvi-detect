import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/mock_auth_service.dart';

// Auth state provider that exposes the user model
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(mockAuthServiceProvider);
  return authService.authStateChanges;
});

// Current user model provider
final userModelProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth state notifier
class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final MockAuthService _authService;
  
  AuthStateNotifier(this._authService) : super(const AsyncValue.loading()) {
    // Initialize with loading state, but quickly check current auth state
    Future.microtask(() {
      if (_authService.currentUser != null) {
        state = AsyncValue.data(_authService.currentUser);
      } else {
        state = const AsyncValue.data(null);
      }
    });
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }
  
  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      await _authService.signInWithGoogle();
      // The state will be updated by the listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // The state will be updated by the listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Auth state notifier provider
final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(mockAuthServiceProvider);
  return AuthStateNotifier(authService);
}); 