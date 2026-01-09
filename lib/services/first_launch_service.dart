import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  FirstLaunchService._internal();
  static final FirstLaunchService instance = FirstLaunchService._internal();

  static const _keyFtueCompleted = 'ql_ftue_completed';

  /// Alias used by routing code. True when FTUE is complete.
  Future<bool> isCompleted() async {
    return hasCompletedFtue();
  }

  /// Returns true if the user has already completed one full
  /// QuietLine flow (pre → breath → post → results).
  Future<bool> hasCompletedFtue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFtueCompleted) ?? false;
  }

  /// Marks the FTUE as completed.
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFtueCompleted, true);
  }

  /// Debug helper: clears the FTUE completion flag.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFtueCompleted);
  }
}