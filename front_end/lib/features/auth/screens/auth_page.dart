import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth_controller.dart';

/// Authentication page with social login options
class AuthPage extends ConsumerWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App logo and name
              _buildAppLogo(theme),
              const SizedBox(height: 24),
              // App title and description
              _buildAppTitle(theme),
              const SizedBox(height: 8),
              _buildAppDescription(theme),
              const Spacer(),
              // Auth buttons
              _buildAppleSignInButton(
                context: context,
                onPressed: () async {
                  try {
                    await authController.signInWithApple();
                  } catch (e) {
                    _showSignInError(context, e.toString());
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildGoogleSignInButton(
                context: context,
                onPressed: () async {
                  try {
                    await authController.signInWithGoogle();
                  } catch (e) {
                    _showSignInError(context, e.toString());
                  }
                },
              ),
              SizedBox(height: size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the app logo widget
  Widget _buildAppLogo(ThemeData theme) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.health_and_safety,
            size: 64,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  /// Build the app title widget
  Widget _buildAppTitle(ThemeData theme) {
    return Center(
      child: Text(
        'VenaCura',
        style: GoogleFonts.manrope(
          textStyle: theme.textTheme.displaySmall,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Build the app description widget
  Widget _buildAppDescription(ThemeData theme) {
    return Center(
      child: Text(
        'Chronic Venous Insufficiency Monitoring',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  /// Show error dialog when sign-in fails
  void _showSignInError(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sign in failed: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Apple sign-in button
Widget _buildAppleSignInButton({
  required BuildContext context,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.apple),
    label: const Text('Continue with Apple'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  );
}

/// Google sign-in button
Widget _buildGoogleSignInButton({
  required BuildContext context,
  required VoidCallback onPressed,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Image.network(
      'https://cdn.iconscout.com/icon/free/png-256/google-160-189824.png',
      height: 24,
      width: 24,
    ),
    label: const Text('Continue with Google'),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  );
} 