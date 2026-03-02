import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloom_app/screens/bloom_breath/models/breath_phase_contracts.dart';
import 'bloom_colors.dart';

enum ThemeVariant {
  midnight,
  morning,
}

// Legacy BloomColors class for backward compatibility and internal logic
class BloomColors {
  static const primary = BloomLightColors.primary;
  static const secondary = BloomLightColors.secondary;
  static const accent = BloomLightColors.accent;
  static const background = BloomLightColors.background;
  static const surface = BloomLightColors.surface;
  static const highlight = BloomLightColors.highlight;
  static const textPrimary = BloomLightColors.textPrimary;
  static const textSecondary = BloomLightColors.textSecondary;

  // Legacy mappings for other components
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
  static const midnightBlue = BloomDarkColors.background;
}

final bloomLightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: BloomLightColors.primary,
    onPrimary: Colors.white,
    secondary: BloomLightColors.secondary,
    onSecondary: BloomLightColors.textPrimary,
    error: Colors.redAccent,
    onError: Colors.white,
    surface: BloomLightColors.surface,
    onSurface: BloomLightColors.textPrimary,
  ),
  scaffoldBackgroundColor: BloomLightColors.background,
  cardColor: BloomLightColors.surface,
  cardTheme: const CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  textTheme: GoogleFonts.interTextTheme(TextTheme(
    headlineLarge: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w600,
      color: BloomLightColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w600,
      color: BloomLightColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w600,
      color: BloomLightColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      color: BloomLightColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      color: BloomLightColors.textPrimary,
    ),
    bodySmall: GoogleFonts.inter(
      color: BloomLightColors.textSecondary,
    ),
  )),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BloomLightColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
  ),
);

final bloomDarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: BloomDarkColors.primary,
    onPrimary: Colors.black87,
    secondary: BloomDarkColors.secondary,
    onSecondary: BloomDarkColors.textPrimary,
    error: Colors.redAccent.shade100,
    onError: Colors.black87,
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
  textTheme: GoogleFonts.interTextTheme(TextTheme(
    headlineLarge: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w600,
      color: BloomDarkColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w600,
      color: BloomDarkColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w600,
      color: BloomDarkColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      color: BloomDarkColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      color: BloomDarkColors.textPrimary,
    ),
    bodySmall: GoogleFonts.inter(
      color: BloomDarkColors.textSecondary,
    ),
  )),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BloomDarkColors.primary,
      foregroundColor: Colors.black87,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
  ),
);

class BloomTheme {
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
        return BloomLightColors.primary;
    }
  }

  static Color getBackgroundColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return BloomDarkColors.background;
      case ThemeVariant.morning:
        return BloomLightColors.background;
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
    switch (phase) {
      case BreathPhaseType.inhale:
        return BloomLightColors.primary;
      case BreathPhaseType.hold:
        return BloomLightColors.highlight;
      case BreathPhaseType.exhale:
        return BloomLightColors.secondary;
      case BreathPhaseType.rest:
        return BloomLightColors.surface;
      case BreathPhaseType.power:
        return BloomLightColors.primary;
      case BreathPhaseType.retention:
        return BloomLightColors.highlight;
      case BreathPhaseType.recovery:
        return BloomLightColors.accent;
    }
  }
}

class BloomGradients {
  static Gradient getHomeGradient(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BloomDarkColors.background,
            BloomDarkColors.surface,
          ],
        );
      case ThemeVariant.morning:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BloomLightColors.background,
            BloomLightColors.surface,
          ],
        );
    }
  }

  static Gradient get steelFlame => getHomeGradient(ThemeVariant.midnight);
  static Gradient get tealFlame => getHomeGradient(ThemeVariant.morning);
}