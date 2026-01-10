// lib/data/affirmations/affirmations_service.dart

import 'affirmations_model.dart';
import 'affirmations_packs.dart';

/// Simple service for getting affirmations.
///
/// For MVP:
/// - No persistence.
/// - Home/Unlock flow should use sequential (day/streak-based) selection.
/// - Date-based "today" selection is kept for future/experiments.
class AffirmationsService {
  const AffirmationsService();

  /// Get all affirmations for a given pack.
  List<Affirmation> getAffirmationsForPack(String packId) {
    return affirmationsByPack[packId] ?? const [];
  }

  /// Sequential (earned) affirmation for a given pack day.
  ///
  /// Day 1 -> index 0, Day 2 -> index 1, etc.
  ///
  /// By default we wrap when day exceeds list length.
  Affirmation? getForPackDay(
    String packId,
    int dayNumber, {
    bool wrap = true,
  }) {
    final list = getAffirmationsForPack(packId);
    if (list.isEmpty) return null;

    final day = dayNumber <= 0 ? 1 : dayNumber;
    final int index;

    if (wrap) {
      index = (day - 1) % list.length;
    } else {
      final i = day - 1;
      index = i < 0
          ? 0
          : (i >= list.length ? list.length - 1 : i);
    }

    return list[index];
  }

  /// Convenience for the Core pack (Day 1 -> core_001).
  Affirmation? getCoreForDay(int dayNumber, {bool wrap = true}) {
    return getForPackDay(AffirmationPackIds.core, dayNumber, wrap: wrap);
  }

  /// Deterministic "today" affirmation for a pack.
  Affirmation? getTodayForPack(
    String packId, {
    DateTime? now,
  }) {
    final list = getAffirmationsForPack(packId);
    if (list.isEmpty) return null;

    final today = now ?? DateTime.now();
    // Normalize to date-only.
    final dayKey = DateTime(today.year, today.month, today.day)
        .millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;

    final index = dayKey % list.length;
    return list[index];
  }

  /// Convenience for the Core pack.
  Affirmation? getTodayCore() {
    return getTodayForPack(AffirmationPackIds.core);
  }

  /// Random affirmation (non-deterministic).
  Affirmation? getRandomFromPack(String packId) {
    final list = getAffirmationsForPack(packId);
    if (list.isEmpty) return null;
    list.shuffle();
    return list.first;
  }
}