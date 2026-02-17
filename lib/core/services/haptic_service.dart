import 'package:flutter/services.dart';
import 'user_preferences_service.dart';

/// Central service for haptic feedback.
/// This ensures consistent tactile feedback across the app.
class HapticService {
  HapticService._();

  /// Very light tap - for subtle interactions or progress.
  static Future<void> light() async {
    if (!UserPreferencesService.instance.hapticEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium tap - for significant actions like completions.
  static Future<void> medium() async {
    if (!UserPreferencesService.instance.hapticEnabled) return;
    
    final intensity = UserPreferencesService.instance.hapticIntensity;
    if (intensity < 0.7) {
      await HapticFeedback.lightImpact();
    } else if (intensity > 1.3) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Heavy tap - for high-impact events.
  static Future<void> heavy() async {
    if (!UserPreferencesService.instance.hapticEnabled) return;

    final intensity = UserPreferencesService.instance.hapticIntensity;
    if (intensity < 0.8) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Selection/Click - standard navigation or selection feedback.
  static Future<void> selection() async {
    if (!UserPreferencesService.instance.hapticEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Silent Pulse - rhythmic haptic feedback for breathing.
  /// [intensity] 0..1 scale.
  static Future<void> silentPulse({double intensity = 0.5}) async {
    if (!UserPreferencesService.instance.hapticEnabled) return;
    
    // Silent Pulse is a premium feature, but the triggering logic 
    // is managed by the caller (BreathController).
    if (intensity < 0.3) {
      await HapticFeedback.lightImpact();
    } else if (intensity > 0.7) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Error/Success vibrations could be added here later if needed.
}
