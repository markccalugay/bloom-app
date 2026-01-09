import 'package:flutter/material.dart';

import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/screens/splash/quiet_splash_screen.dart';
import 'package:quietline_app/screens/welcome/quiet_welcome_screen.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/services/first_launch_service.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';

class QuietEntryScreen extends StatefulWidget {
  const QuietEntryScreen({super.key});

  @override
  State<QuietEntryScreen> createState() => _QuietEntryScreenState();
}

class _QuietEntryScreenState extends State<QuietEntryScreen> {
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
        streak = await QuietStreakService.getCurrentStreak();
      } catch (_) {
        streak = 0;
      }

      if (!mounted) return;
      setState(() {
        _ftueComplete = done;
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

  void _startQuietTime() {
    final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuietBreathScreen(
          sessionId: sessionId,
          streak: _streak,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state (tiny, invisible)
    if (_ftueComplete == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    // FTUE already done → go home
    if (_ftueComplete == true) {
      return const QuietShellScreen();
    }

    // FTUE not done → Splash → Welcome
    return QuietSplashScreen(
      onDone: () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuietWelcomeScreen(
              onStart: _startQuietTime,
            ),
          ),
        );
      },
    );
  }
}