import 'package:flutter/material.dart';

class AppTheme {
  // Agricultural palette per SPEC.md Section 13
  static const Color primaryGreen = Color(0xFF1B5E20);      // Deep Kisan Green
  static const Color secondaryGreen = Color(0xFF2E7D32);    // Field Green
  static const Color paraliGold = Color(0xFFE65100);        // Dry Stubble Ochre / Accent
  static const Color lightBackground = Color(0xFFF9FBF7);   // Soft Off-white
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1A2E1A);
  static const Color textMuted = Color(0xFF556B55);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: paraliGold,
        surface: lightBackground,
      ),
      scaffoldBackgroundColor: lightBackground,
      fontFamilyFallback: const [
        'Noto Sans Devanagari',
        'Noto Sans Gurmukhi',
        'Mukta',
        'Roboto',
      ],
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textDark,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: textDark,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: textMuted,
          height: 1.4,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56), // Minimum 56dp touch target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 2),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC8D6C8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC8D6C8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(fontSize: 16, color: textMuted),
      ),
    );
  }
}
