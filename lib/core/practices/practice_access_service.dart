import '../../data/practices/practice_model.dart';
import '../feature_flags.dart';

class PracticeAccessService {
  const PracticeAccessService();

  bool canAccess(Practice practice) {
    if (practice.tier == PracticeTier.free) return true;

    // MVP: allow premium access via debug flag only
    if (FeatureFlags.debugPremiumEnabled) return true;

    return false;
  }
}