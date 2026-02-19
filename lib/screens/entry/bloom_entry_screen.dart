import 'package:flutter/material.dart';

import 'package:bloom_app/screens/shell/bloom_shell_screen.dart';
import 'package:bloom_app/screens/splash/bloom_splash_screen.dart';
import 'package:bloom_app/screens/welcome/bloom_welcome_screen.dart';
import 'package:bloom_app/screens/bloom_breath/bloom_breath_screen.dart';
import 'package:bloom_app/services/first_launch_service.dart';
import 'package:bloom_app/data/streak/bloom_streak_service.dart';

class BloomEntryScreen extends StatefulWidget {
  const BloomEntryScreen({super.key});

  @override
  State<BloomEntryScreen> createState() => _BloomEntryScreenState();
}

class _BloomEntryScreenState extends State<BloomEntryScreen> {
  bool? _ftueComplete;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final done = await FirstLaunchService.instance.hasCompletedFtue();
      int streak = 0;
      try {
        streak = await BloomStreakService.getCurrentStreak();
      } catch (_) {
        streak = 0;
      }

      if (!mounted) return;
      setState(() {
        // FTUE should only ever run once. If the user has a persisted streak
        // of 1+ (i.e., they've completed at least one session), treat FTUE as complete
        // even if the FTUE flag fails to persist for any reason.
        _ftueComplete = done || streak >= 1;
        _streak = streak;
      });
    } catch (_) {
      // Fail safe: if something goes wrong, treat as NOT completed
      if (!mounted) return;
      setState(() {
        _ftueComplete = false;
        _streak = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state (tiny, invisible)
    if (_ftueComplete == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    // FTUE already done → go home
    if (_ftueComplete == true) {
      return const BloomShellScreen();
    }

    // FTUE not done → Splash → Welcome
    return BloomSplashScreen(
      onDone: () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BloomWelcomeScreen(
              streak: _streak,
              onStart: (ctx) {
                final sessionId =
                    'session-${DateTime.now().millisecondsSinceEpoch}';

                // Use the Welcome screen's context (ctx) to avoid using a disposed context.
                Navigator.of(ctx).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => BloomBreathScreen(
                      sessionId: sessionId,
                      streak: _streak,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}