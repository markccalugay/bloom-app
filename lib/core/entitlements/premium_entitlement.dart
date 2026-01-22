import 'dart:async';

import '../storekit/storekit_service.dart';

/// Single source of truth for premium access.
///
/// Backed by StoreKit entitlement state.
/// UI and feature code must ONLY talk to this class.
class PremiumEntitlement {
  PremiumEntitlement._();

  static final PremiumEntitlement instance = PremiumEntitlement._();

  bool _isInitialized = false;
  bool _isPremium = false;

  /// Call once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize StoreKit
    await StoreKitService.instance.initialize();

    // Sync initial value
    _isPremium = StoreKitService.instance.isPremium.value;

    // Listen for entitlement changes
    StoreKitService.instance.isPremium.addListener(_onPremiumChanged);

    _isInitialized = true;
  }

  void _onPremiumChanged() {
    _isPremium = StoreKitService.instance.isPremium.value;
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