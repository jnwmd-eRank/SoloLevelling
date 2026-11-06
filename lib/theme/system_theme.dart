import 'package:flutter/material.dart';

class SystemTheme {
  // Solo Leveling "The System" Palette
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1A2337);
  static const Color border = Color(0xFF24324D);
  static const Color borderGlow = Color(0xFF00E5FF);

  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color systemPurple = Color(0xFF7C4DFF);
  static const Color alertRed = Color(0xFFFF3366);
  static const Color successGreen = Color(0xFF00E676);
  static const Color rankGold = Color(0xFFFFB300);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: systemPurple,
        surface: surface,
        error: alertRed,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: primaryCyan),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryCyan,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static BoxDecoration hudCardDecoration({
    Color? borderColor,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: borderColor ?? border,
        width: glow ? 1.5 : 1.0,
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: (borderColor ?? primaryCyan).withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }
}
