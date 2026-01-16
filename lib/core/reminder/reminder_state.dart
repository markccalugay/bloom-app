

/// Immutable container for reminder-related local state.
///
/// This model intentionally contains no logic.
/// All rules and decisions live in ReminderService.
class ReminderState {
  const ReminderState({
    required this.hasSeenReminderPrompt,
    required this.hasEnabledReminder,
    required this.lastReminderPromptDate,
    required this.promptCount,
  });

  /// Whether the reminder prompt has ever been shown.
  final bool hasSeenReminderPrompt;

  /// Whether the user has successfully enabled reminders.
  final bool hasEnabledReminder;

  /// The last calendar date the reminder prompt was shown.
  /// Stored as a normalized (year/month/day) DateTime.
  final DateTime? lastReminderPromptDate;

  /// Number of times the reminder prompt has been shown.
  /// Hard-capped at 2 by ReminderService.
  final int promptCount;

  /// Convenience getter for whether the prompt has been shown at least once.
  bool get hasShownAtLeastOnce => promptCount > 0;
}