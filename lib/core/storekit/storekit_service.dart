import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Single responsibility:
/// - Load StoreKit products
/// - Observe purchases
/// - Answer: "Is this user premium?"
class StoreKitService {
  StoreKitService._internal();

  static final StoreKitService instance = StoreKitService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;

  /// Your subscription product IDs
  static const Set<String> _premiumProductIds = {
    'quietline.premium.monthly',
    // add yearly later if needed
  };

  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool _initialized = false;

  /// Call once at app startup
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[StoreKit] Store not available');
      return;
    }

    // Listen for purchase updates
    _purchaseSub = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('[StoreKit] Purchase stream error: $error');
      },
    );

    // Restore purchases to determine entitlement
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    bool premiumFound = false;

    for (final purchase in purchases) {
      if (_premiumProductIds.contains(purchase.productID) &&
          (purchase.status == PurchaseStatus.purchased ||
           purchase.status == PurchaseStatus.restored)) {
        premiumFound = true;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }

    if (isPremium.value != premiumFound) {
      debugPrint('[StoreKit] Premium entitlement = $premiumFound');
      isPremium.value = premiumFound;
    }
  }

  /// Optional cleanup (probably never needed)
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }
}