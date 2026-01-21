import '../feature_flags.dart';

/// Single source of truth for premium access.
/// 
/// Today:
/// - Backed by FeatureFlags (debug / launch-time cache)
/// 
/// Tomorrow:
/// - Backed by StoreKit entitlement state
/// 
/// UI and feature code must ONLY talk to this class.
class PremiumEntitlement {
  PremiumEntitlement._();

  static final PremiumEntitlement instance = PremiumEntitlement._();

  bool _isInitialized = false;
  bool _isPremium = false;

  /// Call once at app startup.
  /// Locks entitlement state for the session.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // MVP backing store (will be replaced by StoreKit)
    _isPremium = FeatureFlags.launchPremiumEnabled;

    _isInitialized = true;
  }

  /// Read-only premium entitlement.
  bool get isPremium {
    if (!_isInitialized) {
      // Fail safe: no entitlement until initialized
      return false;
    }
    return _isPremium;
  }

  /// DEV ONLY
  /// Used by debug menu to simulate entitlement changes.
  /// Requires app restart to take effect (intentional).
  void debugSetPremium(bool value) {
    FeatureFlags.debugPremiumEnabled = value;
  }
}