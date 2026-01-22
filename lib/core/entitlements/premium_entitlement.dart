import 'dart:async';

import '../storekit/storekit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for premium access.
///
/// Backed by StoreKit entitlement state.
/// UI and feature code must ONLY talk to this class.
class PremiumEntitlement {
  PremiumEntitlement._();

  static final PremiumEntitlement instance = PremiumEntitlement._();

  static const String _premiumCacheKey = 'is_premium_cached';

  bool _isInitialized = false;
  bool _isPremium = false;

  /// Call once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load cached premium state for instant UX
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumCacheKey) ?? false;

    // Sync initial value from StoreKit (source of truth)
    _isPremium = StoreKitService.instance.isPremium.value;

    // Listen for entitlement changes
    StoreKitService.instance.isPremium.addListener(_onPremiumChanged);

    _isInitialized = true;
  }

  void _onPremiumChanged() async {
    final newValue = StoreKitService.instance.isPremium.value;
    _isPremium = newValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumCacheKey, newValue);
  }

  /// Read-only premium entitlement.
  bool get isPremium {
    if (!_isInitialized) return false;
    return _isPremium;
  }

  /// Optional cleanup (not required for MVP)
  void dispose() {
    StoreKitService.instance.isPremium.removeListener(_onPremiumChanged);
    _isInitialized = false;
  }
}