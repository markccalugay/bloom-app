import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  FirstLaunchService._internal();
  static final FirstLaunchService instance = FirstLaunchService._internal();

  static const _keyCompleted = 'ql_has_completed_first_session';

  /// Returns true if the user has already completed one full
  /// QuietLine flow (pre → breath → post → results).
  Future<bool> hasCompletedFirstSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCompleted) ?? false;
  }

  /// Marks the first session as completed.
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompleted, true);
  }
}