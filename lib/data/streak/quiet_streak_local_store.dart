import 'package:shared_preferences/shared_preferences.dart';

/// Handles local persistence of streak data on this device.
/// No business logic, just read/write.
class QuietStreakLocalStore {
  QuietStreakLocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kStreakCountKey = 'quiet_streak_count';
  static const String _kLastDateKey = 'quiet_streak_last_date'; // yyyy-MM-dd

  /// Returns the current streak count, or 0 if none saved.
  Future<int> getCurrentStreak() async {
    return _prefs.getInt(_kStreakCountKey) ?? 0;
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

  /// Saves both streak count and last date together.
  Future<void> saveStreak({
    required int count,
    required DateTime lastDate,
  }) async {
    await _prefs.setInt(_kStreakCountKey, count);
    await _prefs.setString(_kLastDateKey, _formatDate(lastDate));
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