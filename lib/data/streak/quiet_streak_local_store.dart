import 'package:shared_preferences/shared_preferences.dart';

/// Handles local persistence of streak data on this device.
/// No business logic, just read/write.
class QuietStreakLocalStore {
  QuietStreakLocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kStreakCountKey = 'quiet_streak_count';
  static const String _kLastDateKey = 'quiet_streak_last_date'; // yyyy-MM-dd
  static const String _kTotalSessionsKey = 'quiet_total_sessions';
  static const String _kTotalSecondsKey = 'quiet_total_seconds';
  static const String _kSessionDatesKey = 'quiet_session_dates';
  static const String _kPracticeUsageKey = 'quiet_practice_usage';

  /// Returns the current streak count, or 0 if none saved.
  Future<int> getCurrentStreak() async {
    return _prefs.getInt(_kStreakCountKey) ?? 0;
  }

  /// Returns total number of sessions completed.
  Future<int> getTotalSessions() async {
    return _prefs.getInt(_kTotalSessionsKey) ?? 0;
  }

  /// Returns total seconds spent in meditation.
  Future<int> getTotalSeconds() async {
    return _prefs.getInt(_kTotalSecondsKey) ?? 0;
  }

  /// Returns the last streak date as a DateTime, or null if none/invalid.
  Future<DateTime?> getLastDate() async {
    final raw = _prefs.getString(_kLastDateKey);
    if (raw == null) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      // If parsing fails for any reason, treat as no date.
      return null;
    }
  }

  /// Returns true if the last completed streak date matches `today` (local date-only).
  Future<bool> hasCompletedToday(DateTime today) async {
    final last = await getLastDate();
    if (last == null) return false;

    final a = DateTime(last.year, last.month, last.day);
    final b = DateTime(today.year, today.month, today.day);
    return a == b;
  }

  /// Saves both streak count and last date together.
  Future<void> saveStreak({
    required int count,
    required DateTime lastDate,
  }) async {
    await _prefs.setInt(_kStreakCountKey, count);
    await _prefs.setString(_kLastDateKey, _formatDate(lastDate));
  }

  /// Increments session count, adds meditation duration, records date, and tracks practice usage.
  Future<void> incrementMetrics(int seconds, {String? practiceId}) async {
    final currentSessions = await getTotalSessions();
    final currentSeconds = await getTotalSeconds();
    await _prefs.setInt(_kTotalSessionsKey, currentSessions + 1);
    await _prefs.setInt(_kTotalSecondsKey, currentSeconds + seconds);

    // Record date
    final today = _formatDate(DateTime.now());
    final dates = _prefs.getStringList(_kSessionDatesKey) ?? [];
    if (!dates.contains(today)) {
      dates.add(today);
      await _prefs.setStringList(_kSessionDatesKey, dates);
    }

    // Track practice usage
    if (practiceId != null) {
      final usageRaw = _prefs.getStringList(_kPracticeUsageKey) ?? [];
      final usageMap = _decodeUsage(usageRaw);
      usageMap[practiceId] = (usageMap[practiceId] ?? 0) + 1;
      await _prefs.setStringList(_kPracticeUsageKey, _encodeUsage(usageMap));
    }
  }

  Future<List<String>> getSessionDates() async {
    return _prefs.getStringList(_kSessionDatesKey) ?? [];
  }

  Future<Map<String, int>> getPracticeUsage() async {
    final raw = _prefs.getStringList(_kPracticeUsageKey) ?? [];
    return _decodeUsage(raw);
  }

  Map<String, int> _decodeUsage(List<String> raw) {
    final result = <String, int>{};
    for (final item in raw) {
      final parts = item.split(':');
      if (parts.length == 2) {
        final id = parts[0];
        final count = int.tryParse(parts[1]) ?? 0;
        result[id] = count;
      }
    }
    return result;
  }

  List<String> _encodeUsage(Map<String, int> usage) {
    return usage.entries.map((e) => '${e.key}:${e.value}').toList();
  }

  /// Optional: clear streak completely (for debugging / reset).
  Future<void> clear() async {
    await _prefs.remove(_kStreakCountKey);
    await _prefs.remove(_kLastDateKey);
  }

  String _formatDate(DateTime d) {
    final dateOnly = DateTime(d.year, d.month, d.day);
    return dateOnly.toIso8601String().split('T').first; // yyyy-MM-dd
  }
}

// Where you create this later:
// final prefs = await SharedPreferences.getInstance();
// final local = QuietStreakLocalStore(prefs);