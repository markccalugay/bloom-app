import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/practices/practice_model.dart';
import '../../data/practices/practice_catalog.dart';
import'../entitlements/premium_entitlement.dart';
import '../../screens/quiet_breath/models/breath_phase_contracts.dart';
import '../../data/practices/reset_pack_model.dart';
import '../../data/practices/reset_pack_catalog.dart';

class PracticeAccessService {
  static const _activePracticeKey = 'active_practice_id';
  static const _activeResetPackKey = 'active_reset_pack_id';

  // Singleton instance
  static final PracticeAccessService instance = PracticeAccessService._internal();
  PracticeAccessService._internal();

  final ValueNotifier<String> activePracticeId = ValueNotifier<String>('core_quiet');
  final ValueNotifier<String?> activeResetPackId = ValueNotifier<String?>(null);

  bool get isResetPackActive => activeResetPackId.value != null;

  /// Call once at app start
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    activePracticeId.value =
        prefs.getString(_activePracticeKey) ?? 'core_quiet';
    activeResetPackId.value = prefs.getString(_activeResetPackKey);
  }

  bool canAccess(Practice practice) {
    if (practice.tier == PracticeTier.free) return true;
    return PremiumEntitlement.instance.isPremium;
  }

  bool isActive(String practiceId) {
    return !isResetPackActive && practiceId == activePracticeId.value;
  }

  bool isPackActive(String packId) {
    return activeResetPackId.value == packId;
  }

  BreathingPracticeContract getActiveContract() {
    if (isResetPackActive) {
      final pack = ResetPackCatalog.all.firstWhere(
        (p) => p.id == activeResetPackId.value,
        orElse: () => ResetPackCatalog.panicReset,
      );
      return pack.contract;
    }

    return PracticeCatalog.all.firstWhere(
      (p) => p.id == activePracticeId.value,
      orElse: () => PracticeCatalog.coreQuiet,
    ).contract;
  }

  ResetPack? getActiveResetPack() {
    if (!isResetPackActive) return null;
    return ResetPackCatalog.all.firstWhere(
      (p) => p.id == activeResetPackId.value,
      orElse: () => ResetPackCatalog.panicReset,
    );
  }

  Future<void> setActivePractice(String practiceId) async {
    final prefs = await SharedPreferences.getInstance();
    activePracticeId.value = practiceId;
    activeResetPackId.value = null; // Clear reset pack when choosing pure practice
    await prefs.setString(_activePracticeKey, practiceId);
    await prefs.remove(_activeResetPackKey);
  }

  Future<void> setActiveResetPack(String? packId) async {
    final prefs = await SharedPreferences.getInstance();
    activeResetPackId.value = packId;
    if (packId != null) {
      await prefs.setString(_activeResetPackKey, packId);
    } else {
      await prefs.remove(_activeResetPackKey);
    }
  }
}