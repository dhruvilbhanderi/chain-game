// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary gradient colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFF00CEC9);
  static const Color gold = Color(0xFFFFD700);

  // Background
  static const Color bgDark = Color(0xFF0D0D1A);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgCardLight = Color(0xFF16213E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB2B2D0);
  static const Color textHint = Color(0xFF6B6B8E);

  // Status
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFFD700);
  static const Color error = Color(0xFFFF6B6B);

  // Chain / Denner
  static const Color dennerColor = Color(0xFFFF6B6B);
  static const Color chainColor = Color(0xFF6C5CE7);
  static const Color winnerColor = Color(0xFFFFD700);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8E44AD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgDark, Color(0xFF0F0F2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.bgCard,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
            displayMedium: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            headlineMedium: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            bodyMedium: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgCardLight,
          hintStyle: const TextStyle(color: AppColors.textHint),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2D2D50), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        useMaterial3: true,
      );
}
