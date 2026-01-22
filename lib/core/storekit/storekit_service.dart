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

  ProductDetails? _premiumProduct;

  /// Your subscription product IDs
  static const Set<String> _premiumProductIds = {
    'quietline.premium.monthly',
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

    final response = await _iap.queryProductDetails(_premiumProductIds);

    if (response.productDetails.isNotEmpty) {
      _premiumProduct = response.productDetails.first;
      debugPrint('[StoreKit] Loaded product: ${_premiumProduct!.id}');
    } else {
      debugPrint('[StoreKit] No products found');
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

  Future<void> purchasePremium() async {
    if (_premiumProduct == null) {
      debugPrint('[StoreKit] purchasePremium called but product not loaded');
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);

    // TODO: This MUST be changed to buyNonConsumable → buyNonConsumable ONLY AFTER
    // confirming product type. Subscriptions require buyNonConsumable() in Flutter IAP.
    await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  /// Optional cleanup (probably never needed)
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }
}