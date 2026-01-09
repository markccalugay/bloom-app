import 'package:flutter/material.dart';

import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/screens/splash/quiet_splash_screen.dart';
import 'package:quietline_app/screens/welcome/quiet_welcome_screen.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/services/first_launch_service.dart';

class QuietEntryScreen extends StatefulWidget {
  const QuietEntryScreen({super.key});

  @override
  State<QuietEntryScreen> createState() => _QuietEntryScreenState();
}

class _QuietEntryScreenState extends State<QuietEntryScreen> {
  bool? _ftueComplete;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final done = await FirstLaunchService.instance.hasCompletedFtue();
      if (!mounted) return;
      setState(() => _ftueComplete = done);
    } catch (_) {
      // Fail safe: if something goes wrong, treat as NOT completed
      if (!mounted) return;
      setState(() => _ftueComplete = false);
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
      return const QuietShellScreen();
    }

    // FTUE not done → Splash → Welcome
    return QuietSplashScreen(
      onDone: () {
        if (!mounted) return;
        final navigator = Navigator.of(context);
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuietWelcomeScreen(
              onStart: () {
                // Note: this callback can fire after QuietEntryScreen has been replaced.
                // Use the captured NavigatorState (root navigator) rather than `mounted`.
                final sessionId =
                    'session-${DateTime.now().millisecondsSinceEpoch}';
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => QuietBreathScreen(
                      sessionId: sessionId,
                      streak: 0,
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