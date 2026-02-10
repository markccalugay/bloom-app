import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/reminder/reminder_service.dart';
import 'core/practices/practice_access_service.dart';
import 'core/notifications/notification_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
// import 'screens/quiet_breath/quiet_breath_screen.dart';
// import 'screens/mood_checkin/mood_checkin_screen.dart';
// import 'screens/mood_checkin/mood_checkin_strings.dart';
import 'screens/entry/quiet_entry_screen.dart';

import 'screens/results/quiet_results_ok_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/streak/quiet_streak_local_store.dart';
import 'data/streak/quiet_streak_repository.dart';
import 'data/streak/quiet_streak_service.dart';

// import 'services/first_launch_service.dart';
// import 'screens/shell/quiet_shell_screen.dart';
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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const AppRestart(child: QuietLineApp()));
  WidgetsBinding.instance.addObserver(
    _ReminderTimezoneObserver(),
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
          // Entry router: Splash → Welcome → (FTUE Quiet Time once) → Home
          home: const QuietEntryScreen(),
        );
      },
    );
  }
}

class DebugResultsEntryScreen extends StatelessWidget {
  const DebugResultsEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Test OK / streak screen
            ElevatedButton(
              onPressed: () async {
                final newStreak = await quietStreakRepo
                    .registerSessionCompletedToday();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuietResultsOkScreen(streak: newStreak, isNew: true),
                  ),
                );
              },
              child: const Text('Test OK (streak) screen'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ReminderTimezoneObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;

    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderService(prefs);

    final needsResync = await reminderService.needsTimezoneResync();
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
    await reminderService.updateStoredTimezone(currentTimezone);
  }
}
