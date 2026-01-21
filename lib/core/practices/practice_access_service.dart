import '../../data/practices/practice_model.dart';
import '../entitlements/premium_entitlement.dart';

class PracticeAccessService {
  const PracticeAccessService();

  bool canAccess(Practice practice) {
    if (practice.tier == PracticeTier.free) return true;

    // MVP: allow premium access via launch-time cached entitlement only
    if (PremiumEntitlement.instance.isPremium) return true;

    return false;
  }
}