import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

/// Authentication controller for managing user authentication state
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthController({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        super(const AsyncValue.loading()) {
    _init();
  }

  /// Initialize the auth controller and listen for auth state changes
  void _init() {
    _auth.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
  }

  /// Sign in with Google account
  Future<UserCredential> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in aborted by user');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Sign in with Apple ID
  Future<UserCredential> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      // Check if the platform is iOS or macOS
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw Exception('Apple Sign-In is only supported on iOS and macOS platforms.');
      }

      // Get Apple ID credentials
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential for Firebase
      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // If the user's name is null, update it using the data from Apple
      if (userCredential.user != null && 
          (userCredential.user!.displayName == null || userCredential.user!.displayName!.isEmpty) &&
          appleCredential.givenName != null) {
        await userCredential.user!.updateDisplayName(
          '${appleCredential.givenName} ${appleCredential.familyName ?? ''}',
        );
      }
      
      return userCredential;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
}); 