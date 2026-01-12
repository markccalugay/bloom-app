import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/data/affirmations/affirmations_model.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';

class AffirmationsUnlockService {
  // Singleton
  AffirmationsUnlockService._();
  static final AffirmationsUnlockService instance =
      AffirmationsUnlockService._();

  static const _kUnlockedIdsKey = 'unlocked_affirmation_ids';
  static const _kLastUnlockDateKey = 'last_affirmation_unlock_date';

  // Prevent double-unlocks when multiple screens call unlock during the same transition.
  Future<Affirmation?>? _inFlightUnlock;

  /// Returns the local calendar date as YYYY-MM-DD
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Affirmation? _firstWhereOrNull(
    List<Affirmation> list,
    bool Function(Affirmation a) test,
  ) {
    for (final a in list) {
      if (test(a)) return a;
    }
    return null;
  }

  /// Returns all unlocked affirmation IDs
  Future<Set<String>> getUnlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kUnlockedIdsKey) ?? [];
    return list.toSet();
  }

  /// Attempts to unlock exactly ONE core affirmation for the given streak day.
  /// Returns the unlocked Affirmation if successful, or null if:
  /// - already unlocked today
  /// - no valid affirmation exists
  Future<Affirmation?> unlockCoreOncePerDay({
    required int streakDay,
  }) async {
    // FTUE safety: we only unlock after the user has actually earned Day 1+.
    if (streakDay < 1) return null;

    // If an unlock is already running, return the same result instead of unlocking twice.
    final existing = _inFlightUnlock;
    if (existing != null) return existing;

    _inFlightUnlock = () async {
      final prefs = await SharedPreferences.getInstance();

      final today = _todayKey();
      final lastUnlockDate = prefs.getString(_kLastUnlockDateKey);

      // Already unlocked today → do nothing
      if (lastUnlockDate == today) {
        return null;
      }

      final unlockedIds =
          (prefs.getStringList(_kUnlockedIdsKey) ?? []).toSet();

      // Mark today's unlock immediately to avoid double-unlock in rare edge cases.
      await prefs.setString(_kLastUnlockDateKey, today);

      // Determine the primary target ID by day
      final targetId = 'core_${streakDay.toString().padLeft(3, '0')}';

      // Pull core list once so we don't re-fetch it.
      final core = coreAffirmations;

      Affirmation? affirmation;

      // Try the ideal ordered ID first
      if (!unlockedIds.contains(targetId)) {
        affirmation = _firstWhereOrNull(
          core,
          (a) => a.id == targetId,
        );
      }

      // Fallback: next locked core affirmation in order
      affirmation ??= _firstWhereOrNull(
        core,
        (a) => !unlockedIds.contains(a.id),
      );

      if (affirmation == null) {
        return null; // nothing left to unlock
      }

      // Persist unlock
      unlockedIds.add(affirmation.id);
      await prefs.setStringList(
        _kUnlockedIdsKey,
        unlockedIds.toList(),
      );

      return affirmation;
    }();

    try {
      return await _inFlightUnlock;
    } finally {
      _inFlightUnlock = null;
    }
  }

  /// Alias used by results routing: unlock one core affirmation for the given streak day
  /// (only once per local calendar day).
  Future<Affirmation?> unlockIfEligibleForToday(int streakDay) {
    return unlockCoreOncePerDay(streakDay: streakDay);
  }

  /// Backwards-compatible alias (older call sites).
  Future<Affirmation?> unlockTodayIfEligible(int streakDay) {
    return unlockCoreOncePerDay(streakDay: streakDay);
  }

  /// Returns the core affirmation for the given streak day ONLY if it is already unlocked.
  /// (Does not unlock anything.)
  Future<Affirmation?> getUnlockedForStreak(int streakDay) async {
    final unlockedIds = await getUnlockedIds();
    final targetId = 'core_${streakDay.toString().padLeft(3, '0')}';
    if (!unlockedIds.contains(targetId)) return null;

    return _firstWhereOrNull(
      coreAffirmations,
      (a) => a.id == targetId,
    );
  }

  /// Backwards-compatible alias (older call sites).
  Future<Affirmation?> getUnlockedForDay(int streakDay) {
    return getUnlockedForStreak(streakDay);
  }
}