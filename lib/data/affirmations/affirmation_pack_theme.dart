import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';

/// Centralized visual theming for affirmation packs.
/// This is the single source of truth for pack backgrounds.
///
/// Both library cards and detail screens should read from here.
/// No UI logic. No widget imports.
class AffirmationPackTheme {
  const AffirmationPackTheme({
    required this.backgroundGradient,
    required this.accentColor,
    required this.borderColor,
  });

  final Gradient backgroundGradient;
  final Color accentColor;
  final Color borderColor;

  /// Lookup by pack id.
  static AffirmationPackTheme forPack(String packId) {
    switch (packId) {
      case AffirmationPackIds.core:
        return _core;

      case AffirmationPackIds.focus:
        return _focus;

      case AffirmationPackIds.sleep:
        return _sleep;

      case AffirmationPackIds.strength:
        return _strength;

      default:
        return _core;
    }
  }

  // --- Pack definitions ---

  /// Core affirmations — MUST strictly follow QuietLine brand colors.
  static final AffirmationPackTheme _core = AffirmationPackTheme(
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        QLColors.primaryTeal,
        QLColors.primaryTeal.withValues(alpha: 0.85),
      ],
    ),
    accentColor: QLColors.primaryTeal,
    borderColor: QLColors.primaryTeal,
  );

  /// Focus — deeper, cooler, performance-oriented.
  static final AffirmationPackTheme _focus = AffirmationPackTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0E2A38), // deep navy-teal
        Color(0xFF163F52),
      ],
    ),
    accentColor: const Color(0xFF5FA8D3),
    borderColor: const Color(0xFF5FA8D3),
  );

  /// Sleep — warm, calm, low-arousal.
  static final AffirmationPackTheme _sleep = AffirmationPackTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2A1F1B), // muted warm brown
        Color(0xFF3A2B24),
      ],
    ),
    accentColor: const Color(0xFFE2B07A),
    borderColor: const Color(0xFFE2B07A),
  );

  /// Strength — grounded, solid, masculine.
  static final AffirmationPackTheme _strength = AffirmationPackTheme(
    backgroundGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2B1E23), // deep maroon
        Color(0xFF40262E),
      ],
    ),
    accentColor: const Color(0xFFB85C6B),
    borderColor: const Color(0xFFB85C6B),
  );
}
