import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'controllers/quiet_breath_controller.dart';
import 'quiet_breath_constants.dart';
import 'widgets/quiet_breath_circle.dart';
import 'widgets/quiet_breath_controls.dart';
import 'widgets/quiet_breath_timer_title.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';
import 'package:quietline_app/core/feature_flags.dart';
import 'package:quietline_app/screens/results/quiet_results_ok_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';

class QuietBreathScreen extends StatefulWidget {
  final String sessionId;

  /// Current streak count to display on the results screen.
  /// Optional with a safe default so existing call sites don't break.
  final int streak;

  const QuietBreathScreen({
    super.key,
    required this.sessionId,
    this.streak = 0,
  });

  @override
  State<QuietBreathScreen> createState() => _QuietBreathScreenState();
}

class _QuietBreathScreenState extends State<QuietBreathScreen>
    with TickerProviderStateMixin {
  late final QuietBreathController controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = QuietBreathController(vsync: this);
    controller.onSessionComplete = _handleSessionComplete;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleSessionComplete() async {
    // Keep mood check-ins reconnectable behind a flag.
    // IMPORTANT: When mood check-ins are enabled, we do NOT increment streak here
    // to avoid double-incrementing (mood flow currently owns that side-effect).
    if (FeatureFlags.moodCheckInsEnabled) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MoodCheckinScreen(
            mode: MoodCheckinMode.post,
            sessionId: widget.sessionId,
            onSubmit: (score) {},
          ),
        ),
      );
      return;
    }

    // Increment streak here — this is the moment the user earns it.
    // FTUE flow: 0 -> 1 happens exactly once.
    final int previous = widget.streak; // 0 on first install
    final int current = await QuietStreakService.registerSessionCompletedToday();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuietResultsOkScreen(
          previousStreak: previous,   // 0
          streak: current,            // 1
          completedToday: true,
          isNew: current == 1,         // FTUE animation trigger
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kQBHeaderTopGap),
            AnimatedBuilder(
              animation: controller.listenable,
              builder: (_, _) => QuietBreathTimerTitle(controller: controller),
            ),
            Expanded(child: QuietBreathCircle(controller: controller)),
            QuietBreathControls(controller: controller),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton(
                  onPressed: () {
                    controller.completeSessionImmediately();
                  },
                  child: const Text(
                    'DEBUG: Skip Session',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}