import 'package:flutter/material.dart';
import 'package:bloom_app/screens/bloom_breath/models/breath_phase_contracts.dart';

enum ThemeVariant {
  midnight,
  morning,
}

class BloomColors {
  // Primary CTA (from Soft Rose / Theme Set 01)
  static const primary = Color(0xFFFFC6CA);

  // Secondary Lavender (Mist Blossom / Theme Set 04)
  static const secondary = Color(0xFFE8DFF5);

  // Accent
  static const accent = Color(0xFFFFD4E5);

  // Background
  static const background = Color(0xFFFAFAFB);

  // Surface
  static const surface = Color(0xFFF1F1F3);

  // Highlight / Growth Glow
  static const highlight = Color(0xFFD2C7E5);

  // Text
  static const textPrimary = Color(0xFF1E1E22);
  static const textSecondary = Color(0xFF6E6E75);

  // Legacy support for other components
  static const primaryTeal = primary;
  static const quietAqua = primary;
  static const slateBlue = primary;
  static const morningMist = secondary;
  static const armorForgeGlow = primary;
  static const armorIronBase = secondary;
  static const steelGray = secondary;
  static const graphiteGray = textSecondary;
  static const calmTeal = primary;
  static const mutedSand = secondary;
  static const sandWhite = background;
  static const skyAsh = secondary;
  static const midnightBlue = Color(0xFF121214); // Matches dark background
}

class BloomDarkColors {
  static const primary = Color(0xFFDEB499);
  static const background = Color(0xFF121214);
  static const surface = Color(0xFF1C1C20);
  static const textPrimary = Color(0xFFEAEAF0);
  static const textSecondary = Color(0xFF9A9AA3);
}

final bloomLightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: BloomColors.primary,
    onPrimary: Colors.black87,
    secondary: BloomColors.secondary,
    onSecondary: Colors.black87,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: BloomColors.surface,
    onSurface: BloomColors.textPrimary,
  ),
  scaffoldBackgroundColor: BloomColors.background,
  cardColor: BloomColors.surface,
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: BloomColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: BloomColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: BloomColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      color: BloomColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      color: BloomColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      color: BloomColors.textSecondary,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BloomColors.primary,
      foregroundColor: Colors.black87,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);

final bloomDarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: BloomDarkColors.primary,
    onPrimary: Colors.black87,
    secondary: BloomColors.secondary.withValues(alpha: 0.8),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: BloomDarkColors.surface,
    onSurface: BloomDarkColors.textPrimary,
  ),
  scaffoldBackgroundColor: BloomDarkColors.background,
  cardColor: BloomDarkColors.surface,
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: BloomDarkColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: BloomDarkColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: BloomDarkColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      color: BloomDarkColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      color: BloomDarkColors.textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      color: BloomDarkColors.textSecondary,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BloomDarkColors.primary,
      foregroundColor: Colors.black87,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);

class BloomTheme {
  // Legacy support for ThemeService
  static ThemeData getTheme(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return bloomDarkTheme;
      case ThemeVariant.morning:
        return bloomLightTheme;
    }
  }

  static Color getPrimaryColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return BloomDarkColors.primary;
      case ThemeVariant.morning:
        return BloomColors.primary;
    }
  }

  static Color getBackgroundColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return BloomDarkColors.background;
      case ThemeVariant.morning:
        return BloomColors.background;
    }
  }

  static String labelForPhase(BreathPhaseType phase) {
    switch (phase) {
      case BreathPhaseType.inhale:
        return 'Inhale';
      case BreathPhaseType.hold:
        return 'Hold';
      case BreathPhaseType.exhale:
        return 'Exhale';
      case BreathPhaseType.rest:
        return 'Rest';
      case BreathPhaseType.power:
        return 'Breathe';
      case BreathPhaseType.retention:
        return 'Hold';
      case BreathPhaseType.recovery:
        return 'Recover';
    }
  }

  static Color colorForPhase(BreathPhaseType phase) {
    // In new theme, we use primary (Soft Rose) for inhale/exhale 
    // and secondary (Lavender) or neutral for others
    switch (phase) {
      case BreathPhaseType.inhale:
        return BloomColors.primary;
      case BreathPhaseType.hold:
        return BloomColors.highlight;
      case BreathPhaseType.exhale:
        return BloomColors.primary.withValues(alpha: 0.8);
      case BreathPhaseType.rest:
        return BloomColors.surface;
      case BreathPhaseType.power:
        return BloomColors.primary;
      case BreathPhaseType.retention:
        return BloomColors.highlight;
      case BreathPhaseType.recovery:
        return BloomColors.accent;
    }
  }
}

class BloomGradients {
  static Gradient getHomeGradient(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BloomDarkColors.background,
            BloomDarkColors.background.withValues(alpha: 0.8),
          ],
        );
      case ThemeVariant.morning:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BloomColors.background,
            BloomColors.secondary,
          ],
        );
    }
  }

  // Legacy support
  static Gradient get steelFlame => getHomeGradient(ThemeVariant.midnight);
  static Gradient get tealFlame => getHomeGradient(ThemeVariant.morning);
}