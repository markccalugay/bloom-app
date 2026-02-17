import 'package:flutter/foundation.dart';

class QuietAnalytics {
  QuietAnalytics._internal();
  static final QuietAnalytics instance = QuietAnalytics._internal();

  /// Logs a subscription purchase attempt.
  /// 
  /// [tier] should be 'weekly', 'monthly', or 'yearly'.
  /// [trialAvailable] is true if the user was shown a trial offer.
  Future<void> logPurchaseAttempt({
    required String tier,
    required bool trialAvailable,
  }) async {
    // In the future, this would send data to a backend or analytics service (e.g. Firebase, Mixpanel).
    // For now, we just log to console in debug mode.
    if (kDebugMode) {
      debugPrint('[Analytics] subscription_purchase_attempt: tier=$tier, trial_available=$trialAvailable');
    }
  }
}
