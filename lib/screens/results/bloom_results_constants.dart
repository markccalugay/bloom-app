import 'package:flutter/material.dart';
import 'package:bloom_app/theme/bloom_theme.dart';
import 'package:bloom_app/theme/bloom_colors.dart';

/// Layout and styling constants specific to the results screens.
class BloomResultsConstants {
  // Layout
  static const double horizontalPadding = 24.0;
  static const double verticalSpacingLarge = 24.0;
  static const double verticalSpacingMedium = 16.0;
  static const double verticalSpacingSmall = 8.0;
  static const double okScreenStreakTopGap = 56.0;

  // Sizes
  static const double streakBadgeSize = 220.0;
  static const double smallFlameSize = 48.0;


  // Colors (Theme-aware mappings)
  static Color get activeFlameTop => BloomLightColors.primary;
  static Color get activeFlameBottom => BloomLightColors.primaryPressed;
  static Color get inactiveFlame => BloomLightColors.textSecondary.withValues(alpha: 0.3);

  // Theme-aware Gradient Getters
  static Gradient getInactiveGradient(BuildContext context) {
    final theme = Theme.of(context);
    // Inactive state uses a subtle blend of surface colors
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.surface,
        theme.colorScheme.onSurface.withValues(alpha: 0.08),
      ],
    );
  }

  static Gradient getActiveGradient(BuildContext context) {
    final theme = Theme.of(context);
    // Active state uses the primary brand gradient
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.secondary,
      ],
    );
  }
}