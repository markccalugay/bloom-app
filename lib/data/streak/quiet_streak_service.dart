import 'quiet_streak_repository.dart';

/// Thin service layer for streak logic.
///
/// UI code should talk to this instead of the repository directly where
/// possible, so we keep a single place to adjust behavior later.
class QuietStreakService {
  /// Repository instance, wired up at app start (e.g., in main()).
  static late QuietStreakRepository repo;

  /// Get the current streak count.
  ///
  /// Delegates to [QuietStreakRepository.getCurrentStreak].
  static Future<int> getCurrentStreak() {
    return repo.getCurrentStreak();
  }

  /// Register that today’s session was completed.
  ///
  /// Returns the updated streak value. Delegates to
  /// [QuietStreakRepository.registerSessionCompletedToday].
  static Future<int> registerSessionCompletedToday() {
    return repo.registerSessionCompletedToday();
  }

  /// Reset/clear the streak, if you ever need it (e.g., debugging).
  ///
  /// Delegates to [QuietStreakRepository.resetStreak].
  static Future<void> resetStreak() {
    return repo.resetStreak();
  }
}