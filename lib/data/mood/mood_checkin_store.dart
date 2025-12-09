// lib/data/mood/mood_checkin_store.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/data/mood/mood_checkin_record.dart';

/// Simple local storage layer for mood check-ins.
///
/// Uses SharedPreferences under the hood, but the rest of the app should only
/// talk to this class. That keeps it easy to swap out later (Hive, backend, etc.).
class MoodCheckinStore {
  static const String _storageKey = 'ql_mood_checkins';

  const MoodCheckinStore();

  /// Save a single record by appending it to the stored list.
  Future<void> save(MoodCheckinRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? <String>[];

    final updated = List<String>.from(existing)..add(record.toJson());
    await prefs.setStringList(_storageKey, updated);
  }

  /// Load all stored records, newest last.
  Future<List<MoodCheckinRecord>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];

    final records = <MoodCheckinRecord>[];
    for (final json in raw) {
      try {
        records.add(MoodCheckinRecord.fromJson(json));
      } catch (_) {
        // If corrupted entry ever appears, skip it instead of crashing.
      }
    }
    return records;
  }

  /// Clear all stored mood check-ins (useful for debugging / reset).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}