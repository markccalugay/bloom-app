import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:quietline_app/services/first_launch_service.dart';

class QuietBreathScreen extends StatefulWidget {
  final String sessionId;

  /// Current streak count to display on the results screen.
  /// Optional with a safe default so existing call sites don't break.
  final int streak;

  const QuietBreathScreen({
    super.key,
    required this.sessionId,
    this.streak = 1,
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

    // MVP path: increment streak on session completion.
    int before = 0;
    int after = 0;
    try {
      before = await QuietStreakService.getCurrentStreak();
      after = await QuietStreakService.registerSessionCompletedToday();

      // Mark FTUE completion (idempotent). This ensures the app boots to Home
      // on subsequent launches after the first completed session.
      await FirstLaunchService.instance.markCompleted();
    } catch (_) {
      // MVP stability: fall back safely.
      after = before;
      try {
        // Even if streak fails, still attempt to mark FTUE as completed.
        await FirstLaunchService.instance.markCompleted();
      } catch (_) {
        // no-op
      }
    }

    if (!mounted) return;

    final bool isNew = after > before;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuietResultsOkScreen(
          streak: after,
          isNew: isNew,
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}