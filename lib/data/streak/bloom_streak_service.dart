import 'package:flutter/foundation.dart';
import 'bloom_streak_repository.dart';

/// Thin service layer for streak logic.
///
/// UI code should talk to this instead of the repository directly where
/// possible, so we keep a single place to adjust behavior later.
class BloomStreakService {
  /// Repository instance, wired up at app start (e.g., in main()).
  static late BloomStreakRepository repo;

  /// Get the current streak count.
  ///
  /// Delegates to [BloomStreakRepository.getCurrentStreak].
  static Future<int> getCurrentStreak() async {
    try {
      return await repo.getCurrentStreak();
    } catch (_) {
      return 0;
    }
  }

  /// Get the total number of sessions completed.
  static Future<int> getTotalSessions() async {
    try {
      return await repo.getTotalSessions();
    } catch (_) {
      return 0;
    }
  }

  /// Get the total meditation time in seconds.
  static Future<int> getTotalSeconds() async {
    try {
      return await repo.getTotalSeconds();
    } catch (_) {
      return 0;
    }
  }

  /// Record a completed session with the given duration in seconds.
  static Future<void> recordSession(int seconds, {String? practiceId}) async {
    try {
      await repo.recordSession(seconds, practiceId: practiceId);
    } catch (e) {
      debugPrint('[BloomStreakService] Error recording session: $e');
    }
  }

  static Future<List<String>> getSessionDates() async {
    try {
      return await repo.getSessionDates();
    } catch (e) {
      debugPrint('[BloomStreakService] Error getting session dates: $e');
      return [];
    }
  }

  static Future<Map<String, int>> getPracticeUsage() async {
    try {
      return await repo.getPracticeUsage();
    } catch (e) {
      debugPrint('[BloomStreakService] Error getting practice usage: $e');
      return {};
    }
  }

  /// Register that today’s session was completed.
  ///
  /// Returns the updated streak value. Delegates to
  /// [BloomStreakRepository.registerSessionCompletedToday].
  static Future<int> registerSessionCompletedToday() async {
    try {
      return await repo.registerSessionCompletedToday();
    } catch (e) {
      debugPrint('[BloomStreakService] Error registering completion: $e');
      // MVP stability: if repo isn't initialized yet or storage fails,
      // avoid breaking the completion flow.
      return await getCurrentStreak();
    }
  }

  /// Returns true if a Bloom session has already been completed today (local date).
  static Future<bool> hasCompletedToday() async {
    try {
      final now = DateTime.now();
      return await repo.hasCompletedToday(now);
    } catch (e) {
      debugPrint('[BloomStreakService] Error checking today\'s completion: $e');
      // MVP fail-safe: assume not completed so flow is not blocked.
      return false;
    }
  }

  /// Check if the user is currently on a streak (streak > 0).
  ///
  /// Returns true if the current streak is greater than zero.
  static Future<bool> isOnStreak() async {
    final streak = await getCurrentStreak();
    return streak > 0;
  }

  /// Reset/clear the streak, if you ever need it (e.g., debugging).
  ///
  /// Delegates to [BloomStreakRepository.resetStreak].
  static Future<void> resetStreak() async {
    try {
      await repo.resetStreak();
    } catch (e) {
      debugPrint('[BloomStreakService] Error resetting streak: $e');
    }
  }
}