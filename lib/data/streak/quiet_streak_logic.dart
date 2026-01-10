/// Result of evaluating a streak update.
class QuietStreakLogicResult {
  final int newStreak;
  final DateTime newDate; // date we should persist (local, truncated)

  const QuietStreakLogicResult({
    required this.newStreak,
    required this.newDate,
  });
}

/// Pure streak logic: given current streak + last date + today,
/// decide the new streak and date.
class QuietStreakLogic {
  const QuietStreakLogic();

  QuietStreakLogicResult evaluate({
    required int currentStreak,
    required DateTime? lastDate,
    required DateTime today,
  }) {
    // Work with date-only (no time component).
    final todayDate = _stripTime(today);

    // No previous record → FTUE stays at 0.
    // First completion should ANIMATE 0 → 1 in the UI, then be persisted.
    if (lastDate == null) {
      return QuietStreakLogicResult(
        newStreak: 0,
        newDate: todayDate,
      );
    }

    final lastDateOnly = _stripTime(lastDate);
    final diffDays = todayDate.difference(lastDateOnly).inDays;

    if (diffDays == 0) {
      // Same calendar day → no change.
      return QuietStreakLogicResult(
        newStreak: currentStreak,
        newDate: todayDate,
      );
    } else if (diffDays == 1) {
      // Yesterday → continue streak.
      return QuietStreakLogicResult(
        newStreak: currentStreak + 1,
        newDate: todayDate,
      );
    } else {
      // Missed one or more days → reset to 0 (will animate again on next completion).
      return QuietStreakLogicResult(
        newStreak: 1,
        newDate: todayDate,
      );
    }
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
}