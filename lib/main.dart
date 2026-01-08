import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/quiet_breath/quiet_breath_screen.dart';
// import 'screens/mood_checkin/mood_checkin_screen.dart';
// import 'screens/mood_checkin/mood_checkin_strings.dart';
import 'theme/ql_theme.dart';

import 'screens/results/quiet_results_ok_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'data/streak/quiet_streak_local_store.dart';
import 'data/streak/quiet_streak_repository.dart';
import 'data/streak/quiet_streak_service.dart';

import 'services/first_launch_service.dart';
//import 'screens/home/quiet_home_screen.dart';
import 'screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/core/feature_flags.dart';

late QuietStreakRepository quietStreakRepo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  runApp(const QuietLineApp());
}

class QuietLineApp extends StatelessWidget {
  const QuietLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: QLTheme.dark,
      /*
      home: Builder(
        builder: (innerContext) {
          // One session id per app start; this will be shared across pre + breath + post.
          final String sessionId = DateTime.now().toIso8601String();

          return Column(
            children: [
              // DEBUG BUTTON (temporary)
              // SafeArea(
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       const store = MoodCheckinStore();
              //       final records = await store.loadAll();
              //
              //       // ignore: avoid_print
              //       print('=== Mood records (${records.length}) ===');
              //       for (final r in records) {
              //         // ignore: avoid_print
              //         print(
              //           '${r.timestamp.toIso8601String()} | ${r.mode} | score: ${r.score}',
              //         );
              //       }
              //     },
              //     child: const Text("DEBUG: Print Moods"),
              //   ),
              // ),

              // THE ACTUAL APP FLOW
              Expanded(
                child: MoodCheckinScreen(
                  mode: MoodCheckinMode.pre,
                  sessionId: sessionId, // pass session id into pre check-in
                  onSubmit: (score) {
                    Navigator.of(innerContext).push(
                      MaterialPageRoute(
                        builder: (_) => QuietBreathScreen(sessionId: sessionId),
                      ),
                    );
                  },
                  onSkip: () {
                    Navigator.of(innerContext).push(
                      MaterialPageRoute(
                        builder: (_) => QuietBreathScreen(sessionId: sessionId),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      */
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
