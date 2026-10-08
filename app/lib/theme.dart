import 'package:flutter/material.dart';

class AppTheme {
  // Agricultural palette per SPEC.md §13 & UX requirements
  static const Color primaryGreen = Color(0xFF1B5E20);      // Deep Kisan Green (4.5:1+ contrast)
  static const Color secondaryGreen = Color(0xFF2E7D32);    // Field Green
  static const Color wheatGold = Color(0xFFD4A017);        // Wheat / Golden Harvest Accent
  static const Color paraliGold = wheatGold;               // Alias for backwards compatibility
  static const Color warmBackground = Color(0xFFFAF9F5);   // Light warm background
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1C2B1C);         // High-contrast primary text
  static const Color textMuted = Color(0xFF526352);        // Secondary text
  static const Color warningRed = Color(0xFFD32F2F);       // Red only for errors / warnings

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: wheatGold,
        error: warningRed,
        surface: cardBackground,
      ),
      scaffoldBackgroundColor: warmBackground,
      fontFamily: 'Noto Sans',
      fontFamilyFallback: const [
        'Noto Sans Devanagari',
        'Noto Sans Gurmukhi',
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
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
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
        bodySmall: TextStyle(
          fontSize: 14,
          color: textMuted,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5EDE5), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56), // Minimum 56dp touch target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
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
            borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC8D6C8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC8D6C8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: warningRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: warningRed, width: 2),
        ),
        labelStyle: const TextStyle(fontSize: 16, color: textMuted),
      ),
    );
  }
}

class AppColors {
  static const Color primary = AppTheme.primaryGreen;
  static const Color primaryDark = Color(0xFF0E3D12);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color textDark = AppTheme.textDark;
  static const Color textMuted = AppTheme.textMuted;
  static const Color gold = AppTheme.wheatGold;
}

