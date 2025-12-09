import 'package:flutter/material.dart';

class QLColors {
  static const background = Color(0xFF111821); // <- your dark gritty navy
  static const primaryTeal = Color(0xFF3B8F86);
  static const textHigh = Colors.white;
  static const textLow  = Color(0x99FFFFFF); // 60% white
  static const dangerRed = Color(0xFFDD4A48); // 988 text
  static const Color navBarBackground = Color(0xFFE5E7EA);
  static const Color navIconActive = primaryTeal;
  static const Color navIconInactive = Color(0xFF6D747C);
}

class QLTheme {
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: QLColors.background,
    colorScheme: ColorScheme.dark(
      surface: QLColors.background,
      primary: QLColors.primaryTeal,
      secondary: QLColors.primaryTeal,
      error: QLColors.dangerRed,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: QLColors.textHigh,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: QLColors.textHigh,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: QLColors.textLow,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
  );
}