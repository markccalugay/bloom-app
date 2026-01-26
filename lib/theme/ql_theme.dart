import 'package:flutter/material.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';

class QLColors {
  static const background = Color(0xFF111821);
  static const primaryTeal = Color(0xFF3B8F86);
  static const textHigh = Colors.white;
  static const ringTrack = Color(0x44FFFFFF); // softened neutral for radial track
  static const textLow  = Color(0x99FFFFFF);
  static const dangerRed = Color(0xFFDD4A48);
  static const Color navBarBackground = Color(0xFFE5E7EA);
  static const Color navIconActive = primaryTeal;
  static const Color navIconInactive = Color(0xFF6D747C);
}

class QLGradients {
  // ── Soft tier (early / low streak)
  static const Gradient softPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2430),
      Color(0xFF111821),
    ],
  );

  static const List<Gradient> softSecondary = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF18222D),
        Color(0xFF0F151D),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1C2632),
        Color(0xFF121922),
      ],
    ),
  ];

  // ── Grounded tier (mid streak)
  static const Gradient groundedPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF20303A),
      Color(0xFF141C23),
    ],
  );

  static const List<Gradient> groundedSecondary = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1F2D36),
        Color(0xFF131B22),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF22333F),
        Color(0xFF151E26),
      ],
    ),
  ];

  // ── Steady tier (high streak)
  static const Gradient steadyPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF24424A),
      Color(0xFF162128),
    ],
  );

  static const List<Gradient> steadySecondary = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2A4B53),
        Color(0xFF18242B),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF213E45),
        Color(0xFF151F25),
      ],
    ),
  ];
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
        return QLColors.primaryTeal;
      case BreathPhaseType.hold:
        return const Color(0xFF6D747C);
      case BreathPhaseType.exhale:
        return QLColors.primaryTeal.withValues(alpha: 0.85);
      case BreathPhaseType.rest:
        return QLColors.primaryTeal.withValues(alpha: 0.35);
      case BreathPhaseType.power:
        return QLColors.primaryTeal;
      case BreathPhaseType.retention:
        return QLColors.textLow;
      case BreathPhaseType.recovery:
        return QLColors.primaryTeal;
    }
  }
}