import 'dart:async';
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
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/screens/practices/quiet_practice_library_screen.dart';

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
  int? _countdownValue;
  Timer? _countdownTimer;

  void _startCountdown() {
    setState(() {
      _countdownValue = 3;
    });
    SoundscapeService.instance.playCountdown(3);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdownValue! > 1) {
          _countdownValue = _countdownValue! - 1;
          SoundscapeService.instance.playCountdown(_countdownValue!);
        } else {
          _countdownValue = null;
          _countdownTimer?.cancel();
          controller.play();
        }
      });
    });
  }

  Future<void> _handleCancel() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'End your session early?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Discipline is built in the moments we choose to stay. Stopping now will not count toward your daily goals.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'End Session',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(); // Go back to home
    }
  }

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
    _countdownTimer?.cancel();
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

    // Refresh contract from service to ensure we have the latest selection
    // if the user changed it just before the countdown.
    final latestContract = PracticeAccessService.instance.getActiveContract();
    controller.setContract(latestContract);

    // Check if today was already completed BEFORE this session.
    final bool hadCompletedTodayBeforeSession =
        await QuietStreakService.hasCompletedToday();

    // Increment streak here — this is the moment the user earns it.
    // FTUE flow: 0 -> 1 happens exactly once.
    final int previous = widget.streak; // 0 on first install
    final int current = await QuietStreakService.registerSessionCompletedToday();

    // Record metrics (total sessions + total time + practice usage)
    final int durationSeconds = controller.contract.cycles *
        controller.contract.phases.fold(0, (int sum, p) => sum + p.seconds);
    await QuietStreakService.recordSession(
      durationSeconds,
      practiceId: controller.contract.id,
    );

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
                  _buildPracticeSelector(),
                  const SizedBox(height: 12),
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
                  ignoring: _hasStarted || _countdownValue != null,
                  child: QuietBreathControls(
                    controller: controller,
                    hasStarted: _hasStarted,
                    isPlaying: controller.isPlaying,
                    onStart: _startCountdown,
                  ),
                ),
              ),
            ),
            // PRE-SESSION BACK BUTTON
            if (!_hasStarted && _countdownValue == null)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Go back',
                  splashRadius: 24,
                ),
              ),

            // IN-SESSION PAUSE/PLAY (TOP LEFT)
            if (_showPauseIcon && _countdownValue == null)
              Positioned(
                top: 8,
                left: 8,
                child: AnimatedOpacity(
                  opacity: _showPauseIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: AnimatedBuilder(
                    animation: controller.listenable,
                    builder: (_, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
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
                        const SizedBox(width: 4),
                        ListenableBuilder(
                          listenable: SoundscapeService.instance,
                          builder: (context, _) {
                            final isMuted = SoundscapeService.instance.isMuted;
                            return IconButton(
                              icon: Icon(
                                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                SoundscapeService.instance.toggleMute();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // IN-SESSION CANCEL (TOP RIGHT)
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedBuilder(
                animation: controller.listenable,
                builder: (context, _) {
                  if (_hasStarted && !controller.isPlaying && _countdownValue == null) {
                    return TextButton(
                      onPressed: _handleCancel,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // COUNTDOWN OVERLAY
            if (_countdownValue != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: Text(
                      '$_countdownValue',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 80,
                      ),
                    ),
                  ),
                ),
              ),

            // DEBUG LAYER (HIDDEN UNLESS IN DEBUG)
            if (kDebugMode && _countdownValue == null) ...[
              // Move debug info and skip session here
              Positioned(
                bottom: 80,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.completeSessionImmediately();
                      },
                      child: const Text(
                        'DEBUG: Skip Session',
                        style: TextStyle(color: Colors.redAccent, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                          height: 1.2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DEBUG · ${controller.contract.name}'),
                            for (final phase in controller.contract.phases)
                              Text(
                                '${phase.type.name[0].toUpperCase()}${phase.type.name.substring(1)}: ${phase.seconds}s',
                              ),
                            Text('Cycles: ${controller.contract.cycles}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeSelector() {
    final theme = Theme.of(context);
    final accessService = PracticeAccessService.instance;

    return ValueListenableBuilder<String>(
      valueListenable: accessService.activePracticeId,
      builder: (context, activeId, _) {
        final practiceName = activeId.replaceAll('_', ' ').toUpperCase();
        return InkWell(
          onTap: () async {
            if (_hasStarted || _countdownValue != null) {
              // Show warning during session
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: theme.colorScheme.surface,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    'Practice cannot be changed while in session.',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
              );
              return;
            }

            // Navigate to library to change practice
            HapticFeedback.lightImpact();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QuietPracticeLibraryScreen()),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVE PRACTICE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  practiceName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}