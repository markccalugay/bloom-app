/// Central switches for MVP vs V2+ features.
/// Keep this dumb and obvious.
class FeatureFlags {
  static const bool moodCheckInsEnabled = false; // MVP: OFF
  static const bool distressResultsEnabled = false; // MVP: OFF

  // DEV toggle (can be changed via side menu)
  static bool debugPremiumEnabled = false;

  // 🔒 Cached at app launch (release-like behavior)
  static late final bool launchPremiumEnabled;

  /// Call once at app startup to lock premium state
  static void initialize() {
    launchPremiumEnabled = debugPremiumEnabled;
  }
}