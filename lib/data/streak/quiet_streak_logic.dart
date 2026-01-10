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

    // No previous record → FTUE starts at 0, first completion moves to 1.
    if (lastDate == null) {
      return QuietStreakLogicResult(
        newStreak: currentStreak <= 0 ? 1 : currentStreak,
        newDate: todayDate,
      );
    }

    final lastDateOnly = _stripTime(lastDate);
    final diffDays = todayDate.difference(lastDateOnly).inDays;

    if (diffDays == 0) {
      // Same calendar day → keep current streak.
      final streak = currentStreak <= 0 ? 1 : currentStreak;
      return QuietStreakLogicResult(
        newStreak: streak,
        newDate: todayDate,
      );
    } else if (diffDays == 1) {
      // Yesterday → continue streak.
      final base = currentStreak <= 0 ? 1 : currentStreak + 1;
      return QuietStreakLogicResult(
        newStreak: base,
        newDate: todayDate,
      );
    } else {
      // Missed one or more days → reset to 1.
      return QuietStreakLogicResult(
        newStreak: 1,
        newDate: todayDate,
      );
    }
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
}