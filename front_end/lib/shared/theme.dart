import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light theme color scheme
final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xFF0061A4),
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFD1E4FF),
  onPrimaryContainer: const Color(0xFF001D36),
  secondary: const Color(0xFF535F70),
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFD7E3F7),
  onSecondaryContainer: const Color(0xFF101C2B),
  error: const Color(0xFFBA1A1A),
  onError: Colors.white,
  errorContainer: const Color(0xFFFFDAD6),
  onErrorContainer: const Color(0xFF410002),
  background: const Color(0xFFF8FDFF),
  onBackground: const Color(0xFF001F25),
  surface: const Color(0xFFF8FDFF),
  onSurface: const Color(0xFF001F25),
  outline: const Color(0xFF73777F),
  surfaceVariant: const Color(0xFFDFE2EB),
  onSurfaceVariant: const Color(0xFF43474E),
);

// Dark theme color scheme
final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: const Color(0xFF2B9CFF),
  onPrimary: const Color(0xFF003258),
  primaryContainer: const Color(0xFF004880),
  onPrimaryContainer: const Color(0xFFD1E4FF),
  secondary: const Color(0xFFBBC7DB),
  onSecondary: const Color(0xFF253141),
  secondaryContainer: const Color(0xFF3B4858),
  onSecondaryContainer: const Color(0xFFD7E3F7),
  error: const Color(0xFFFFB4AB),
  onError: const Color(0xFF690005),
  errorContainer: const Color(0xFF93000A),
  onErrorContainer: const Color(0xFFFFDAD6),
  background: const Color(0xFF001F25),
  onBackground: const Color(0xFFA6EEFF),
  surface: const Color(0xFF001F25),
  onSurface: const Color(0xFFA6EEFF),
  outline: const Color(0xFF8D9199),
  surfaceVariant: const Color(0xFF43474E),
  onSurfaceVariant: const Color(0xFFC3C7CF),
);

// This is a helper function to get text theme
TextTheme getTextTheme(Brightness brightness) {
  return GoogleFonts.manropeTextTheme(
    brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: getTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: lightColorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: getTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: darkColorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
} 