import 'package:flutter/material.dart';

/// Layout and styling constants specific to the results screens.
class QuietResultsConstants {
  // Layout
  static const double horizontalPadding = 24.0;
  static const double verticalSpacingLarge = 24.0;
  static const double verticalSpacingMedium = 16.0;
  static const double verticalSpacingSmall = 8.0;
  static const double okScreenStreakTopGap = 56.0;

  // Sizes
  static const double streakBadgeSize = 136.0;
  static const double smallFlameSize = 36.0;

  // Colors (tweak values to better match your palette)
  static const Color activeFlameTop = Color(0xFF3BA89C);   // teal-ish
  static const Color activeFlameBottom = Color(0xFF2F716C);
  static const Color inactiveFlame = Color(0xFF4A4F54);    // muted gray
  static const Color softWaveColor = Color(0x26FFFFFF);    // very subtle white (15% alpha)

  // Gradient for inactive streak flames (big + small)
  static const LinearGradient inactiveGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5E6874), // top
      Color(0xFF313841), // bottom
    ],
  );

  // Gradient for active streak flames (big + small)
  static const Gradient streakGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      activeFlameTop,
      activeFlameBottom,
    ],
  );
}