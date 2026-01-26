import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'controllers/quiet_breath_controller.dart';
import 'quiet_breath_constants.dart';
import 'widgets/quiet_breath_circle.dart';
import 'widgets/quiet_breath_controls.dart';
import 'widgets/quiet_breath_timer_title.dart';
import 'models/breath_phase_contracts.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';
import 'package:quietline_app/core/feature_flags.dart';
import 'package:quietline_app/screens/results/quiet_results_ok_screen.dart';
import 'package:quietline_app/screens/results/quiet_session_complete_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';

class QuietBreathScreen extends StatefulWidget {
  final String sessionId;

  /// Current streak count to display on the results screen.
  /// Optional with a safe default so existing call sites don't break.
  final int streak;

  final BreathingPracticeContract? contract;

  const QuietBreathScreen({
    super.key,
    required this.sessionId,
    this.streak = 0,
    this.contract,
  });

  @override
  State<QuietBreathScreen> createState() => _QuietBreathScreenState();
}

class _QuietBreathScreenState extends State<QuietBreathScreen>
    with TickerProviderStateMixin {
  late final QuietBreathController controller;

  bool _hasStarted = false;
  bool _showPauseIcon = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = QuietBreathController(vsync: this);
    if (widget.contract != null) {
      controller.setContract(widget.contract!);
    }
    controller.onSessionComplete = _handleSessionComplete;

    controller.listenable.addListener(() {
      if (controller.isPlaying && !_hasStarted) {
        _hasStarted = true;
        HapticFeedback.selectionClick();
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted) {
            setState(() {
              _showPauseIcon = true;
            });
          }
        });
      }
    });
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

    // Check if today was already completed BEFORE this session.
    final bool hadCompletedTodayBeforeSession =
        await QuietStreakService.hasCompletedToday();

    // Increment streak here — this is the moment the user earns it.
    // FTUE flow: 0 -> 1 happens exactly once.
    final int previous = widget.streak; // 0 on first install
    final int current = await QuietStreakService.registerSessionCompletedToday();

    if (!mounted) return;

    // Only show the streak/results screen on the FIRST completion of the day.
    if (!hadCompletedTodayBeforeSession) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuietResultsOkScreen(
            previousStreak: previous,
            streak: current,
            completedToday: true,
            isNew: current == 1,
          ),
        ),
      );
    } else {
      // Subsequent sessions today skip the streak screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuietSessionCompleteScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: kQBHeaderTopGap),
                  AnimatedBuilder(
                    animation: controller.listenable,
                    builder: (_, _) => QuietBreathTimerTitle(controller: controller),
                  ),
                  Expanded(child: QuietBreathCircle(controller: controller)),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _hasStarted ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: _hasStarted,
                  child: QuietBreathControls(
                    controller: controller,
                    hasStarted: _hasStarted,
                    isPlaying: controller.isPlaying,
                  ),
                ),
              ),
            ),
            if (kDebugMode)
              Positioned(
                top: 12,
                right: 12,
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
            if (kDebugMode)
              Positioned(
                top: 48,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEBUG · ${controller.contract.name}'),
                        const SizedBox(height: 4),
                        for (final phase in controller.contract.phases)
                          Text(
                            '${phase.type.name[0].toUpperCase()}${phase.type.name.substring(1)}: ${phase.seconds}s',
                          ),
                        const SizedBox(height: 4),
                        Text('Cycles: ${controller.contract.cycles}'),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showPauseIcon)
              Positioned(
                top: 8,
                left: 8,
                child: AnimatedOpacity(
                  opacity: _showPauseIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: AnimatedBuilder(
                    animation: controller.listenable,
                    builder: (_, _) => IconButton(
                      icon: Icon(
                        controller.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 22,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        controller.toggle();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}