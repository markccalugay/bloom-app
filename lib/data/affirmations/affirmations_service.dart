// lib/data/affirmations/affirmations_service.dart

import 'affirmations_model.dart';
import 'affirmations_packs.dart';

/// Simple service for getting daily / random affirmations.
///
/// For MVP:
/// - No persistence.
/// - "Affirmation of the day" is deterministic based on date.
class AffirmationsService {
  const AffirmationsService();

  /// Get all affirmations for a given pack.
  List<Affirmation> getAffirmationsForPack(String packId) {
    return affirmationsByPack[packId] ?? const [];
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