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

    // No previous record → first-ever completion.
    // UI can animate 0 → 1, and we persist 1 as the new streak.
    if (lastDate == null) {
      return QuietStreakLogicResult(
        newStreak: 1,
        newDate: todayDate,
      );
    }

    final lastDateOnly = _stripTime(lastDate);
    final diffDays = todayDate.difference(lastDateOnly).inDays;

    // Defensive guard: if device clock/timezone shifts make lastDate appear "in the future",
    // treat it as the same day and do not change the streak.
    if (diffDays <= 0) {
      // Same calendar day (or clock skew) → no change.
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
      // Missed one or more days → reset streak to 1 on the next completion.
      // (The UI can still animate 0 → 1 if the stored streak was 0.)
      return QuietStreakLogicResult(
        newStreak: 1,
        newDate: todayDate,
      );
    }
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
}