import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quietline_app/core/app_initializer.dart';
import 'package:quietline_app/core/app_restart.dart';
import 'package:quietline_app/core/theme/theme_service.dart';
import 'package:quietline_app/core/notifications/notification_service.dart';
import 'package:quietline_app/core/timezone/timezone_service.dart';
import 'package:quietline_app/core/reminder/reminder_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/entry/quiet_entry_screen.dart';
import 'core/entitlements/premium_entitlement.dart';
import 'core/backup/backup_coordinator.dart';

void main() async {
  final reminderService = await AppInitializer.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const AppRestart(child: QuietLineApp()));
  
  WidgetsBinding.instance.addObserver(
    _ReminderAndBackupObserver(reminderService),
  );
}


class QuietLineApp extends StatelessWidget {
  const QuietLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeService.instance.themeData,
          builder: (context, child) => QuietDebugDock(child: child!),
          home: const QuietEntryScreen(),
        );
      },
    );
  }
}

class _ReminderAndBackupObserver extends WidgetsBindingObserver {
  _ReminderAndBackupObserver(this._reminderService);
  final ReminderService _reminderService;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Trigger background backup for Premium users
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (PremiumEntitlement.instance.isPremium) {
        debugPrint('[BACKUP] App moving to background (Premium). Triggering backup.');
        await BackupCoordinator.instance.runBackup();
      }
    }

    if (state != AppLifecycleState.resumed) return;

    final prefs = await SharedPreferences.getInstance();
    
    final needsResync = await _reminderService.needsTimezoneResync();
    if (!needsResync) return;

    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');

    if (hour == null || minute == null) return;

    final notificationService = NotificationService();
    await notificationService.initialize();

    await notificationService.rebuildDaily(
      time: TimeOfDay(hour: hour, minute: minute),
    );

    await TimezoneService.initialize();
    final currentTimezone =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    await _reminderService.updateStoredTimezone(currentTimezone);
  }
}
