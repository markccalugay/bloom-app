import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  FirstLaunchService._internal();
  static final FirstLaunchService instance = FirstLaunchService._internal();

  static const _keyFtueCompleted = 'bloom_ftue_completed';
  static const _keyHomeHintSeen = 'bloom_home_hint_seen';
  static const _keyArmorOnboardingSeen = 'bloom_armor_onboarding_seen';
  static const _keyHasCompletedFirstSession = 'bloom_has_completed_first_session';

  /// Alias used by routing code. True when FTUE is complete.
  Future<bool> isCompleted() async {
    return hasCompletedFtue();
  }

  /// Returns true if the user has already completed one full
  /// Bloom flow (pre → breath → post → results).
  Future<bool> hasCompletedFtue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFtueCompleted) ?? false;
  }

  /// Marks the FTUE as completed.
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFtueCompleted, true);
  }

  /// Returns true if the one-time Home hint has been shown.
  Future<bool> hasSeenHomeHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHomeHintSeen) ?? false;
  }

  /// Marks the one-time Home hint as shown.
  Future<void> markHomeHintSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHomeHintSeen, true);
  }

  /// Returns true if the one-time Armor Room onboarding has been shown.
  Future<bool> hasSeenArmorOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyArmorOnboardingSeen) ?? false;
  }

  /// Marks the one-time Armor Room onboarding as shown.
  Future<void> markArmorOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyArmorOnboardingSeen, true);
  }

  /// Returns true if the user has completed their first Bloom session.
  ///
  /// This is intentionally separate from FTUE completion, because FTUE may include
  /// other steps depending on routing.
  Future<bool> hasCompletedFirstSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasCompletedFirstSession) ?? false;
  }

  /// Marks the first Bloom session as completed.
  Future<void> markCompletedFirstSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasCompletedFirstSession, true);
  }

  /// Debug helper: clears the Home hint seen flag.
  Future<void> resetHomeHint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHomeHintSeen);
  }

  /// Debug helper: clears the first session completion flag.
  Future<void> resetFirstSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasCompletedFirstSession);
  }

  /// Debug helper: clears all FirstLaunchService keys.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFtueCompleted);
    await prefs.remove(_keyHomeHintSeen);
    await prefs.remove(_keyArmorOnboardingSeen);
    await prefs.remove(_keyHasCompletedFirstSession);
  }

  /// Debug helper: returns a snapshot of FTUE-related flags.
  Future<Map<String, bool>> debugStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ftueCompleted': prefs.getBool(_keyFtueCompleted) ?? false,
      'hasSeenHomeHint': prefs.getBool(_keyHomeHintSeen) ?? false,
      'hasSeenArmorOnboarding': prefs.getBool(_keyArmorOnboardingSeen) ?? false,
      'hasCompletedFirstSession':
          prefs.getBool(_keyHasCompletedFirstSession) ?? false,
    };
  }
}