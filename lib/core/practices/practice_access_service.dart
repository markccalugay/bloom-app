import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/practices/practice_model.dart';
import '../../data/practices/practice_catalog.dart';
import'../entitlements/premium_entitlement.dart';
import '../../screens/quiet_breath/models/breath_phase_contracts.dart';

class PracticeAccessService {
  static const _activePracticeKey = 'active_practice_id';

  // Singleton instance
  static final PracticeAccessService instance = PracticeAccessService._internal();
  PracticeAccessService._internal();

  final ValueNotifier<String> activePracticeId = ValueNotifier<String>('core_quiet');

  /// Call once at app start
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    activePracticeId.value =
        prefs.getString(_activePracticeKey) ?? 'core_quiet';
  }

  bool canAccess(Practice practice) {
    if (practice.tier == PracticeTier.free) return true;
    return PremiumEntitlement.instance.isPremium;
  }

  bool isActive(String practiceId) {
    return practiceId == activePracticeId.value;
  }

  BreathingPracticeContract getActiveContract() {
    return PracticeCatalog.all.firstWhere(
      (p) => p.id == activePracticeId.value,
      orElse: () => PracticeCatalog.coreQuiet,
    ).contract;
  }

  Future<void> setActivePractice(String practiceId) async {
    final prefs = await SharedPreferences.getInstance();
    activePracticeId.value = practiceId;
    await prefs.setString(_activePracticeKey, practiceId);
  }
}