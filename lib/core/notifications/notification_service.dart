import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const int _dailyReminderId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Must be called before any notification work.
  Future<void> initialize() async {
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final settings = InitializationSettings(
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  /// Request notification permission from the OS.
  Future<bool> requestPermission() async {
    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin == null) return false;

    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? false;
  }

  /// Schedule a daily local notification at a given time.
  Future<void> scheduleDaily({
    required TimeOfDay time,
  }) async {
    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: false,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Quiet Time',
      'Take a moment to return to stillness.',
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancels the existing daily reminder notification.
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  /// Rebuilds the daily reminder by cancelling the existing
  /// notification and scheduling a new one at the given time.
  Future<void> rebuildDaily({
    required TimeOfDay time,
  }) async {
    await cancelDailyReminder();
    await scheduleDaily(time: time);
  }
}