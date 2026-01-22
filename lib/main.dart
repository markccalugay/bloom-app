import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'screens/quiet_breath/quiet_breath_screen.dart';
// import 'screens/mood_checkin/mood_checkin_screen.dart';
// import 'screens/mood_checkin/mood_checkin_strings.dart';
import 'theme/ql_theme.dart';
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

import 'package:timezone/data/latest.dart' as tz;

late QuietStreakRepository quietStreakRepo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PremiumEntitlement.instance.initialize();
  debugPrint('[BOOT] premium=${PremiumEntitlement.instance.isPremium}');
  tz.initializeTimeZones();

  final prefs = await SharedPreferences.getInstance();
  quietStreakRepo = QuietStreakRepository(
    localStore: QuietStreakLocalStore(prefs),
  );

  QuietStreakService.repo = quietStreakRepo;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const AppRestart(child: QuietLineApp()));
}

class QuietLineApp extends StatelessWidget {
  const QuietLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: QLTheme.dark,
      // Entry router: Splash → Welcome → (FTUE Quiet Time once) → Home
      home: const QuietEntryScreen(),

      /*
      // FTUE: On first install, start with Quiet Time.
      // After the first completed session, boot into the app shell (Home).
      home: FutureBuilder<bool>(
        future: FirstLaunchService.instance.hasCompletedFirstSession(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final hasCompleted = snapshot.data!;
          final sessionId = DateTime.now().toIso8601String();

          // First launch (FTUE): go straight into Quiet Time.
          if (!hasCompleted) {
            // MVP: mood check-ins are disabled. Keep the original FTUE path behind a flag.
            return QuietBreathScreen(sessionId: sessionId, streak: 0);
            // V2 (optional): re-enable the original FTUE pre-checkin flow.
            // if (FeatureFlags.moodCheckInsEnabled) {
            //   return MoodCheckinScreen(
            //     mode: MoodCheckinMode.pre,
            //     sessionId: sessionId,
            //     onSubmit: (_) {
            //       Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (_) => QuietBreathScreen(
            //             sessionId: sessionId,
            //             streak: 0,
            //           ),
            //         ),
            //       );
            //     },
            //     onSkip: () {
            //       Navigator.of(context).push(
            //         MaterialPageRoute(
            //           builder: (_) => QuietBreathScreen(
            //             sessionId: sessionId,
            //             streak: 0,
            //           ),
            //         ),
            //       );
            //     },
            //   );
            // }
          }

          // Post-FTUE: go into the app shell (Home).
          return const QuietShellScreen();
        },
      ),
      */
      // home: const DebugResultsEntryScreen(),
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
