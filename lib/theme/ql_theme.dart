import 'package:flutter/material.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';

enum ThemeVariant {
  quietLine,
  nordic,
  quietLineLight,
  orchidBreeze,
}

class QLColors {
  // QuietLine (Base)
  static const background = Color(0xFF111821);
  static const primaryTeal = Color(0xFF3B8F86);

  // Nordic (Alternative Dark)
  static const nordicBackground = Color(0xFF0F141A);
  static const nordicPrimary = Color(0xFF7F8A99);

  // QuietLine Light
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightPrimary = Color(0xFF3B8F86);

  // Orchid Breeze (Feminine Light)
  static const orchidBackground = Color(0xFFF9F5FF);
  static const orchidPrimary = Color(0xFF9D7BBA);
  static const orchidText = Color(0xFF2D1E3E);

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

  // ── Light Mode Gradients
  static const Gradient lightPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F4F7),
    ],
  );

  static const List<Gradient> lightSecondary = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE6F0F3), // Subtle teal tint
        Color(0xFFFFFFFF),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFE9F2F5),
      ],
    ),
  ];

  // ── Orchid Mode Gradients
  static const Gradient orchidPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF6EAFF),
      Color(0xFFFFFFFF),
    ],
  );

  static const List<Gradient> orchidSecondary = [
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFF3E5FF),
        Color(0xFFEAD6FF),
      ],
    ),
    LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFEAD6FF),
        Color(0xFFF8EFFF),
      ],
    ),
  ];

  static Gradient getPrimaryGradient(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.quietLine:
      case ThemeVariant.nordic:
        return softPrimary; // Default dark
      case ThemeVariant.quietLineLight:
        return lightPrimary;
      case ThemeVariant.orchidBreeze:
        return orchidPrimary;
    }
  }

  static List<Gradient> getSecondaryGradients(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.quietLine:
      case ThemeVariant.nordic:
        return softSecondary;
      case ThemeVariant.quietLineLight:
        return lightSecondary;
      case ThemeVariant.orchidBreeze:
        return orchidSecondary;
    }
  }
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

  static ThemeData nordic = dark.copyWith(
    scaffoldBackgroundColor: QLColors.nordicBackground,
    colorScheme: ColorScheme.dark(
      surface: QLColors.nordicBackground,
      primary: QLColors.nordicPrimary,
      secondary: QLColors.nordicPrimary,
      error: QLColors.dangerRed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.nordicPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
  );

  static ThemeData orchid = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: QLColors.orchidBackground,
    colorScheme: ColorScheme.light(
      surface: QLColors.orchidBackground,
      primary: QLColors.orchidPrimary,
      secondary: QLColors.orchidPrimary,
      onSurface: QLColors.orchidText,
      error: QLColors.dangerRed,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: QLColors.orchidText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: QLColors.orchidText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF6B587E),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.orchidPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
  );

  static ThemeData quietLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: QLColors.lightBackground,
    colorScheme: ColorScheme.light(
      surface: QLColors.lightBackground,
      primary: QLColors.lightPrimary,
      secondary: QLColors.lightPrimary,
      onSurface: QLColors.background,
      error: QLColors.dangerRed,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: QLColors.background,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: QLColors.background,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Color(0xFF6D747C),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
  );

  static ThemeData getTheme(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.quietLine:
        return dark;
      case ThemeVariant.nordic:
        return nordic;
      case ThemeVariant.quietLineLight:
        return quietLight;
      case ThemeVariant.orchidBreeze:
        return orchid;
    }
  }

  static Color getPrimaryColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.quietLine:
        return QLColors.primaryTeal;
      case ThemeVariant.nordic:
        return QLColors.nordicPrimary;
      case ThemeVariant.quietLineLight:
        return QLColors.lightPrimary;
      case ThemeVariant.orchidBreeze:
        return QLColors.orchidPrimary;
    }
  }

  static Color getBackgroundColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.quietLine:
        return QLColors.background;
      case ThemeVariant.nordic:
        return QLColors.nordicBackground;
      case ThemeVariant.quietLineLight:
        return QLColors.lightBackground;
      case ThemeVariant.orchidBreeze:
        return QLColors.orchidBackground;
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