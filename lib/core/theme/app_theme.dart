import 'package:flutter/material.dart';

/// App theme configuration for ZenFocus.
class AppTheme {
  AppTheme._();

  // Focus mode colors (deep blue/indigo)
  static const Color focusPrimary = Color(0xFF3F51B5);
  static const Color focusBackground = Color(0xFF1A237E);
  static const Color focusSurface = Color(0xFF283593);
  static const Color focusAccent = Color(0xFF7C4DFF);

  // Rest mode colors (soft green/teal)
  static const Color restPrimary = Color(0xFF00897B);
  static const Color restBackground = Color(0xFF004D40);
  static const Color restSurface = Color(0xFF00695C);
  static const Color restAccent = Color(0xFF64FFDA);

  // Neutral colors (paused/idle)
  static const Color neutralPrimary = Color(0xFF607D8B);
  static const Color neutralBackground = Color(0xFF37474F);
  static const Color neutralSurface = Color(0xFF455A64);
  static const Color neutralAccent = Color(0xFF90A4AE);

  // Common colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA726);

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: focusPrimary,
        secondary: focusAccent,
        surface: Colors.white,
        error: error,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: focusPrimary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: focusPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: focusPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: focusPrimary, width: 2),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: focusAccent,
        secondary: focusAccent,
        surface: const Color(0xFF1E1E1E),
        error: error,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        color: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: focusAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: focusAccent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: focusAccent, width: 2),
        ),
      ),
    );
  }

  /// Get background color based on timer state.
  static Color getBackgroundColor({
    required bool isRunning,
    required bool isPaused,
    required bool isRestMode,
    required bool isDark,
  }) {
    if (isRestMode) return isDark ? restBackground : restPrimary.withOpacity(0.1);
    if (isPaused) return isDark ? neutralBackground : neutralPrimary.withOpacity(0.1);
    if (isRunning) return isDark ? focusBackground : focusPrimary.withOpacity(0.1);
    return isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  }

  /// Get primary color based on timer state.
  static Color getPrimaryColor({
    required bool isRunning,
    required bool isPaused,
    required bool isRestMode,
  }) {
    if (isRestMode) return restPrimary;
    if (isPaused) return neutralPrimary;
    if (isRunning) return focusPrimary;
    return neutralPrimary;
  }
}