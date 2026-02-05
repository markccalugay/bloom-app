import 'quiet_streak_local_store.dart';
import 'quiet_streak_logic.dart';

/// Public API for anything that needs streak information.
///
/// For now this is local-only. Later you can plug in account/remote sync
/// here without changing the rest of the app.
class QuietStreakRepository {
  QuietStreakRepository({
    required QuietStreakLocalStore localStore,
    QuietStreakLogic? logic,
  })  : _local = localStore,
        _logic = logic ?? const QuietStreakLogic();

  final QuietStreakLocalStore _local;
  final QuietStreakLogic _logic;

  /// Called when a qualifying session has completed *today*.
  /// Returns the updated streak count.
  Future<int> registerSessionCompletedToday() async {
    final current = await _local.getCurrentStreak();
    final last = await _local.getLastDate();
    final now = DateTime.now();

    final result = _logic.evaluate(
      currentStreak: current,
      lastDate: last,
      today: now,
    );

    await _local.saveStreak(
      count: result.newStreak,
      lastDate: result.newDate,
    );

    return result.newStreak;
  }

  /// Returns the current streak without changing it.
  Future<int> getCurrentStreak() {
    return _local.getCurrentStreak();
  }

  /// Returns total sessions from local storage.
  Future<int> getTotalSessions() {
    return _local.getTotalSessions();
  }

  /// Returns total seconds from local storage.
  Future<int> getTotalSeconds() {
    return _local.getTotalSeconds();
  }

  /// Records a completed session's duration.
  Future<void> recordSession(int seconds) {
    return _local.incrementMetrics(seconds);
  }

  /// Returns true if a quiet session has already been completed today (local date-only).
  Future<bool> hasCompletedToday(DateTime today) {
    return _local.hasCompletedToday(today);
  }

  /// Optional helper to wipe streak (for debugging or a “reset progress” feature).
  Future<void> clearStreak() {
    return _local.clear();
  }

  /// Alias for clearStreak() because some callers use resetStreak.
  Future<void> resetStreak() {
    return clearStreak();
  }
}

// Somewhere near app startup, you’ll create the repository:
// final prefs = await SharedPreferences.getInstance();
// final streakRepo = QuietStreakRepository(
//   localStore: QuietStreakLocalStore(prefs),
// );
//
// final newStreak = await streakRepo.registerSessionCompletedToday();