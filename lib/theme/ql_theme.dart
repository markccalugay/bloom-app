import 'package:flutter/material.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';

enum ThemeVariant {
  midnight,
  morning,
  charcoal,
}

class QLColors {
  // ── Light Mode — “Morning Calm” ──
  // Core Brand
  static const slateBlue = Color(0xFF2B3E51);    // Primary
  static const quietAqua = Color(0xFF4FA6A1);    // Secondary
  static const desertSand = Color(0xFFE8D1A7);   // Tertiary
  static const warmGray = Color(0xFF9BA4AB);     // Alternate

  // Accents
  static const morningMist = Color(0xFFD7EBE7);  // Accent 1
  static const clayBeige = Color(0xFFDABF9F);    // Accent 2
  static const skyAsh = Color(0xFFBCC6CA);       // Accent 3
  static const deepStone = Color(0xFF45515A);    // Accent 4

  // Utility
  static const charcoalInk = Color(0xFF2B2F33);  // Primary Text
  static const graphiteGray = Color(0xFF5E6874); // Secondary Text
  static const offWhiteFog = Color(0xFFF5F4F1);  // Primary BG
  static const paleStone = Color(0xFFEEE9E3);    // Secondary BG

  // Semantic
  static const steadyGreen = Color(0xFF4B8E76);  // Success
  static const brickRed = Color(0xFFC65A54);     // Error
  static const cautionAmber = Color(0xFFE1B259); // Warning
  static const tranquilBlue = Color(0xFF5DA3B3); // Info

  // ── Dark Mode — “Midnight Composure” ──
  // Core Brand
  static const midnightBlue = Color(0xFF1D2731); // Primary
  static const calmTeal = Color(0xFF3F8E89);     // Secondary
  static const steelGray = Color(0xFF5E6874);    // Tertiary
  static const mutedSand = Color(0xFFE8DCC6);    // Alternate

  // Accents
  static const deepTeal = Color(0xFF2E6D69);     // Accent 1
  static const warmBronze = Color(0xFFA17E57);   // Accent 2
  static const fadedSky = Color(0xFF729E99);     // Accent 3
  static const cloudGray = Color(0xFFC6C2B8);    // Accent 4 / Secondary Text (Dark)

  // Utility
  static const sandWhite = Color(0xFFF5F4F1);    // Primary Text (identical to offWhiteFog)
  static const deepCharcoal = Color(0xFF11161C); // Primary BG (Dark)
  static const ironGray = Color(0xFF232B33);     // Secondary BG (Dark)

  // Semantic
  static const gentleEmerald = Color(0xFF6FBF9E); // Success
  static const softCrimson = Color(0xFFB35A57);   // Error
  static const mutedAmber = Color(0xFFD4A758);    // Warning
  static const horizonBlue = Color(0xFF67B4C2);   // Info
  
  // ── Armor Design System ──
  // Core Armor Neutrals (Midnight Composure compatible)
  static const armorIronDark   = Color(0xFF45515A); // Lightened: deepStone
  static const armorIronBase   = Color(0xFF708090); // Lightened: slate gray
  static const armorIronLight  = Color(0xFFD1D7DD); // Lightened: soft silver highlight

  // Armor Outline / Stroke
  static const armorOutline    = Color(0xFF4A565F); // aligns w/ deepStone

  // Forging / Progress Accents (Warm, restrained)
  static const armorForgeWarm  = Color(0xFF7A5C3A); // muted bronze
  static const armorForgeGlow  = Color(0xFFA17E57); // reuses warmBronze

  // Locked State (Silhouette)
  static const armorLockedFill     = Color(0xFF141A20); // near background
  static const armorLockedLine     = Color(0xFF232B33); // ironGray
  static const armorLockedFillDark = Color(0xFF1E262D); // Raised value for Dark Mode visibility
  static const armorLockedLineDark = Color(0xFF2F3A44); // Raised value for Dark Mode visibility

  // Unlocked / Polished Style
  static const armorIronUnlocked  = Color(0xFF8FAFB0); // "Earned" - slight teal bias, mid-value
  static const armorIronSaturated = Color(0xFF89D6CE); // polished metallic teal

  // Glow / Presence
  static final armorUnlockedGlow  = const Color(0xFF3F8E89).withValues(alpha: 0.12);

  // ── Component & Legacy Mapping ──
  static const ringTrack = Color(0x1A000000); // 10% black for Light mode default
  
  // These mapping getters adapt based on context if needed, 
  // but for raw static access we default to brand core identity.
  static const background = deepCharcoal;
  static const primaryTeal = calmTeal;
}

class QLGradients {
  // ── Flame Gradient System ──

  // 1. Teal Flame (Core Identity)
  static const Gradient tealFlame = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [QLColors.calmTeal, Color(0xFF2C6C68)],
  );

  // 2. Amber Flame (High Streak / Mastery)
  static const Gradient amberFlame = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [QLColors.mutedSand, Color(0xFFC7A86E)],
  );

  // 3. Steel Flame (Reset / Pause State)
  static const Gradient steelFlame = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [QLColors.steelGray, Color(0xFF313841)],
  );

  // 4. Midnight Flame (Inactive / Reflection Mode)
  static const Gradient midnightFlame = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [QLColors.midnightBlue, Color(0xFF0E141B)],
  );

  // Mapping to current theme
  static Gradient getPrimaryGradient(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return tealFlame;
      case ThemeVariant.morning:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [QLColors.quietAqua, QLColors.slateBlue.withValues(alpha: 0.8)],
        );
      case ThemeVariant.charcoal:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [QLColors.steelGray, QLColors.deepStone],
        );
    }
  }

  static Gradient getHomeGradient(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1C24), Color(0xFF132B34)],
        );
      case ThemeVariant.morning:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Color(0xFFE2E6EA)],
        );
      case ThemeVariant.charcoal:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141A20), Color(0xFF1A2229)],
        );
    }
  }

  static Color getResultsWaveColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
      case ThemeVariant.charcoal:
        return const Color(0x26FFFFFF); // 15% white
      case ThemeVariant.morning:
        return const Color(0x1A000000); // 10% black
    }
  }

  static Gradient getHomeGradient(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1C24), Color(0xFF132B34)],
        );
      case ThemeVariant.morning:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Color(0xFFE2E6EA)],
        );
    }
  }

  static Color getResultsWaveColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return const Color(0x26FFFFFF); // 15% white
      case ThemeVariant.morning:
        return const Color(0x1A000000); // 10% black
    }
  }

  static List<Gradient> getSecondaryGradients(ThemeVariant variant) {
    return [tealFlame, amberFlame, steelFlame, midnightFlame];
  }
}

class QLTheme {
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: QLColors.deepCharcoal, // Ultra-dark premium base
    colorScheme: const ColorScheme.dark(
      surface: QLColors.ironGray,
      primary: QLColors.calmTeal,
      secondary: QLColors.fadedSky,
      error: QLColors.softCrimson,
      onSurface: QLColors.sandWhite,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: QLColors.sandWhite,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: QLColors.sandWhite,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: QLColors.sandWhite,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: QLColors.cloudGray,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.calmTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: QLColors.steelGray,
      thickness: 1,
    ),
  );

  static ThemeData morning = quietLight; // Alias for Morning variant

  static ThemeData charcoal = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1F24),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF242B31),
      primary: QLColors.steelGray,
      secondary: QLColors.deepStone,
      onSurface: QLColors.armorIronLight,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: QLColors.armorIronLight),
      bodySmall: TextStyle(fontSize: 12, color: QLColors.armorIronDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.deepStone,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  static ThemeData quietLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: QLColors.offWhiteFog,
    colorScheme: const ColorScheme.light(
      surface: QLColors.paleStone,
      primary: QLColors.slateBlue,
      secondary: QLColors.quietAqua,
      error: QLColors.brickRed,
      onSurface: QLColors.charcoalInk,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: QLColors.charcoalInk,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: QLColors.charcoalInk,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: QLColors.charcoalInk,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: QLColors.graphiteGray,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QLColors.quietAqua,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: QLColors.skyAsh,
      thickness: 1,
    ),
  );

  // Black & White Adaptive Framework
  static ThemeData blackAndWhite(bool isDark) {
    if (isDark) {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1114),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1A1A1A),
          primary: Colors.white,
          secondary: Color(0xFFBDBDBD),
          onSurface: Color(0xFFE8E8E8),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFE8E8E8)),
          bodySmall: TextStyle(color: Color(0xFF707070)),
        ),
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          primary: Colors.black,
          secondary: Color(0xFF333333),
          onSurface: Color(0xFF111111),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF333333)),
          bodySmall: TextStyle(color: Color(0xFF999999)),
        ),
      );
    }
  }

  static ThemeData getTheme(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return dark;
      case ThemeVariant.morning:
        return quietLight;
      case ThemeVariant.charcoal:
        return charcoal;
    }
  }

  static Color getPrimaryColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return QLColors.calmTeal;
      case ThemeVariant.morning:
        return QLColors.slateBlue;
      case ThemeVariant.charcoal:
        return QLColors.deepStone;
    }
  }

  static Color getBackgroundColor(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.midnight:
        return QLColors.deepCharcoal;
      case ThemeVariant.morning:
        return QLColors.offWhiteFog;
      case ThemeVariant.charcoal:
        return const Color(0xFF1A1F24);
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
        return QLColors.calmTeal;
      case BreathPhaseType.hold:
        return QLColors.steelGray;
      case BreathPhaseType.exhale:
        return QLColors.calmTeal.withValues(alpha: 0.8);
      case BreathPhaseType.rest:
        return QLColors.steelGray.withValues(alpha: 0.5);
      case BreathPhaseType.power:
        return QLColors.calmTeal;
      case BreathPhaseType.retention:
        return QLColors.steelGray;
      case BreathPhaseType.recovery:
        return QLColors.calmTeal;
    }
  }
}