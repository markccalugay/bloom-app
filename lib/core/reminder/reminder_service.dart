import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'reminder_state.dart';
import '../notifications/notification_service.dart';
import '../backup/backup_coordinator.dart';
import '../entitlements/premium_entitlement.dart';

enum ReminderEnableResult {
  enabled,
  denied,
}

/// Central authority for reminder eligibility and persistence.
/// This service contains NO UI logic and NO OS-level notification logic.
/// It only answers questions and records user intent.
///
/// v1 scope:
/// - Decide whether the reminder prompt may be shown
/// - Persist reminder-related state locally
///
/// TODO (v1.1):
/// Add optional “Enable Reminder” entry in the side menu so users
/// can manually enable reminders after dismissing the initial prompts.
class ReminderService {
  ReminderService(this._prefs);

  final SharedPreferences _prefs;

  // ---- Storage keys ----

  static const String _kHasSeenReminderPrompt =
      'hasSeenReminderPrompt';
  static const String _kHasEnabledReminder =
      'hasEnabledReminder';
  static const String _kLastReminderPromptDate =
      'lastReminderPromptDate';
  static const String _kReminderPromptCount =
      'reminderPromptCount';
  static const String _kLastKnownTimezone = 'lastKnownTimezone';

  // ---- Public API ----

  /// Returns the current reminder state loaded from local storage.
  ReminderState loadState() {
    final bool hasSeenPrompt =
        _prefs.getBool(_kHasSeenReminderPrompt) ?? false;

    final bool hasEnabledReminder =
        _prefs.getBool(_kHasEnabledReminder) ?? false;

    final String? storedDate =
        _prefs.getString(_kLastReminderPromptDate);

    final DateTime? lastPromptDate =
        storedDate != null ? DateTime.tryParse(storedDate) : null;

    final int promptCount =
        _prefs.getInt(_kReminderPromptCount) ?? 0;

    return ReminderState(
      hasSeenReminderPrompt: hasSeenPrompt,
      hasEnabledReminder: hasEnabledReminder,
      lastReminderPromptDate: lastPromptDate,
      promptCount: promptCount,
    );
  }

  /// Determines whether the reminder prompt is eligible to be shown.
  ///
  /// This function is intentionally pure and side-effect free.
  /// Timing, delays, and UI concerns are handled elsewhere.
  bool shouldShowReminderPrompt({
    required bool ftueCompleted,
    required int bloomTimeSessionCount,
  }) {
    final ReminderState state = loadState();

    if (!ftueCompleted) return false;
    if (bloomTimeSessionCount < 1) return false;
    if (state.hasEnabledReminder) return false;
    if (state.promptCount >= 2) return false;

    if (state.lastReminderPromptDate != null) {
      final DateTime last = _normalizeDate(state.lastReminderPromptDate!);
      final DateTime today = _normalizeDate(DateTime.now());

      if (last.isAtSameMomentAs(today)) {
        return false;
      }
    }

    return true;
  }

  /// Marks that the reminder prompt has been shown and dismissed
  /// (either via "Later" or "Set a reminder").
  Future<void> markReminderPromptSeen() async {
    final ReminderState state = loadState();
    final int nextCount = state.promptCount + 1;

    await _prefs.setBool(_kHasSeenReminderPrompt, true);
    await _prefs.setInt(_kReminderPromptCount, nextCount);
    await _prefs.setString(
      _kLastReminderPromptDate,
      _normalizeDate(DateTime.now()).toIso8601String(),
    );
  }

  /// Attempts to enable reminders.
  ///
  /// Phase 3 responsibility:
  /// - Ask OS for permission (later)
  /// - Schedule notification (later)
  /// - Persist state on success
  ///
  /// For now, this method only records intent and returns a placeholder result.
  Future<ReminderEnableResult> enableReminder({
    required TimeOfDay time,
  }) async {
    final notificationService = NotificationService();

    // Initialize notification plugin (safe to call multiple times)
    await notificationService.initialize();

    // Ask OS for permission
    final bool granted = await notificationService.requestPermission();

    if (!granted) {
      // User explicitly denied permission — respect it
      await markReminderPromptSeen();
      return ReminderEnableResult.denied;
    }

    // Permission granted — persist time + schedule notification
    await saveReminderTime(time);
    await notificationService.scheduleDaily(time: time);

    final String currentTimezone =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    await _prefs.setString(_kLastKnownTimezone, currentTimezone);

    // Mark reminder as enabled only after successful scheduling
    await markReminderEnabled();

    // Trigger backup if Premium
    if (PremiumEntitlement.instance.isPremium) {
      BackupCoordinator.instance.runBackup();
    }

    return ReminderEnableResult.enabled;
  }

  /// Marks that the user successfully enabled reminders.
  /// This should ONLY be called after OS permission is granted
  /// and a notification is scheduled.
  Future<void> markReminderEnabled() async {
    await _prefs.setBool(_kHasEnabledReminder, true);
  }

  /// Persists the user-selected reminder time.
  /// Scheduling is handled elsewhere.
  Future<void> saveReminderTime(TimeOfDay time) async {
    await _prefs.setInt('reminderHour', time.hour);
    await _prefs.setInt('reminderMinute', time.minute);
  }

  /// Returns true if the device timezone has changed since
  /// the reminder was last scheduled.
  Future<bool> needsTimezoneResync() async {
    final String? storedTimezone =
        _prefs.getString(_kLastKnownTimezone);

    if (storedTimezone == null) {
      return false;
    }

    final String currentTimezone =
        (await FlutterTimezone.getLocalTimezone()).identifier;

    return storedTimezone != currentTimezone;
  }

  /// Updates the stored timezone after a successful resync.
  Future<void> updateStoredTimezone(String timezone) async {
    await _prefs.setString(_kLastKnownTimezone, timezone);
  }

  // ---- Helpers ----

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
