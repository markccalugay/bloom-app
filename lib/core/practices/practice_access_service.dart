import '../../data/practices/practice_model.dart';
import '../entitlements/premium_entitlement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PracticeAccessService {
  static const _activePracticeKey = 'active_practice_id';
  static String _activePracticeId = 'core_quiet';

  const PracticeAccessService();

  /// Call once at app start
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _activePracticeId =
        prefs.getString(_activePracticeKey) ?? 'core_quiet';
  }

  bool canAccess(Practice practice) {
    if (practice.tier == PracticeTier.free) return true;
    return PremiumEntitlement.instance.isPremium;
  }

  bool isActive(String practiceId) {
    return practiceId == _activePracticeId;
  }

  String get activePracticeId => _activePracticeId;

  Future<void> setActivePractice(String practiceId) async {
    final prefs = await SharedPreferences.getInstance();
    _activePracticeId = practiceId;
    await prefs.setString(_activePracticeKey, practiceId);
  }
}