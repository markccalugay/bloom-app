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
    'quietline.premium.weekly',
    'quietline.premium.monthly.v2',
    'quietline.premium.yearly',
  };

  /// All valid product IDs for entitlement (including grandfathered)
  static const Set<String> _allValidPremiumProductIds = {
    ..._premiumProductIds,
    'quietline.premium.monthly', // Grandfathered
  };

  final Map<String, ProductDetails> _products = {};

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

    if (response.error != null) {
      debugPrint('[StoreKit] Error loading products: ${response.error}');
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[StoreKit] Products not found: ${response.notFoundIDs}');
    }

    if (response.productDetails.isNotEmpty) {
      for (final product in response.productDetails) {
        _products[product.id] = product;
        debugPrint('[StoreKit] Loaded product: ${product.id} - ${product.price}');
      }
    } else {
      debugPrint('[StoreKit] No products found after query');
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
      if (_allValidPremiumProductIds.contains(purchase.productID) &&
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

  Future<void> purchasePremium(String productId) async {
    final product = _products[productId];
    if (product == null) {
      debugPrint('[StoreKit] purchasePremium called for $productId but product not loaded');
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    // Subscriptions require buyNonConsumable() in Flutter IAP.
    await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  /// Explicit restore action (used by Paywall UI)
  Future<void> restorePurchases() async {
    if (!_initialized) {
      debugPrint('[StoreKit] restorePurchases called before initialize — initializing now');
      await initialize();
      return;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[StoreKit] restorePurchases failed: Store not available');
      return;
    }

    debugPrint('[StoreKit] restorePurchases started');
    await _iap.restorePurchases();
  }

  /// Optional cleanup (probably never needed)
  void dispose() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _initialized = false;
  }
}