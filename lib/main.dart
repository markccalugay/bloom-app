import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/reminder/reminder_service.dart';
import 'core/practices/practice_access_service.dart';
import 'core/notifications/notification_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'screens/entry/quiet_entry_screen.dart';
import 'core/backup/backup_coordinator.dart';
import 'core/auth/auth_service.dart';
import 'core/api/backend_service.dart';
import 'data/affirmations/affirmations_unlock_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/streak/quiet_streak_local_store.dart';
import 'data/streak/quiet_streak_repository.dart';
import 'data/streak/quiet_streak_service.dart';

import 'package:quietline_app/core/entitlements/premium_entitlement.dart';
import 'package:quietline_app/core/app_restart.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';

import 'package:quietline_app/core/theme/theme_service.dart';
import 'package:quietline_app/core/timezone/timezone_service.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'data/forge/forge_service.dart';

late QuietStreakRepository quietStreakRepo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StoreKitService.instance.initialize();
  await PremiumEntitlement.instance.initialize();
  await ThemeService.instance.initialize();
  await SoundscapeService.instance.initialize();
  debugPrint('[BOOT] premium=${PremiumEntitlement.instance.isPremium}');
  await TimezoneService.initialize();

  final prefs = await SharedPreferences.getInstance();
  quietStreakRepo = QuietStreakRepository(
    localStore: QuietStreakLocalStore(prefs),
  );

  QuietStreakService.repo = quietStreakRepo;
  await PracticeAccessService.instance.initialize();
  await ForgeService.instance.initialize();
  final reminderService = ReminderService(prefs);

  // Initialize Backup/Restore
  final backendService = BackendService(
    baseUrl: 'https://quietline-backend-zwzwtdwllfiumgiopjwd.a.run.app', // Placeholder URL
  );
  BackupCoordinator.instance = BackupCoordinator(
    backendService: backendService,
    authService: AuthService.instance,
    streakRepo: quietStreakRepo,
    forgeService: ForgeService.instance,
    affirmationsService: AffirmationsUnlockService.instance,
    themeService: ThemeService.instance,
    reminderService: reminderService,
  );

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
