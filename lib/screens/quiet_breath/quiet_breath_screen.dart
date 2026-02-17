import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quietline_app/core/services/quiet_debug_actions.dart';
import 'package:quietline_app/core/services/quiet_logger.dart';
import 'package:quietline_app/core/services/quiet_debug_actions.dart';
import 'package:quietline_app/core/services/quiet_logger.dart';
import 'controllers/quiet_breath_controller.dart';
import 'quiet_breath_constants.dart';
import 'widgets/quiet_breath_circle.dart';
import 'widgets/quiet_breath_controls.dart';
import 'widgets/quiet_breath_timer_title.dart';
import 'models/breath_phase_contracts.dart';
import 'package:quietline_app/screens/results/quiet_results_ok_screen.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/screens/practices/quiet_practice_library_screen.dart';
import 'package:quietline_app/services/first_launch_service.dart';

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
  bool _isFirstSession = false;

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
    
    // Pause immediately if playing
    final wasPlaying = controller.isPlaying;
    if (wasPlaying) {
      controller.pause();
    }

    
    // Pause immediately if playing
    final wasPlaying = controller.isPlaying;
    if (wasPlaying) {
      controller.pause();
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierDismissible: false,
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
      SoundscapeService.instance.stop();
      SoundscapeService.instance.stop();
      Navigator.of(context).pop(); // Go back to home
    } else if (wasPlaying && mounted) {
      // Resume if it was playing before
      controller.play();
    } else if (wasPlaying && mounted) {
      // Resume if it was playing before
      controller.play();
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

    // Auto-start soundscape atmosphere on screen entry
    SoundscapeService.instance.play();

    _checkFirstSession();

    if (kDebugMode) {
      QuietDebugActions.instance.registerAction('Skip Session', () {
        QuietLogger.instance.info('Debug: Skipping session...');
        _handleSessionComplete();
      });
    }

    if (kDebugMode) {
      QuietDebugActions.instance.registerAction('Skip Session', () {
        QuietLogger.instance.info('Debug: Skipping session...');
        _handleSessionComplete();
      });
    }

    controller.listenable.addListener(() {
      if (mounted) setState(() {}); // Trigger rebuilds for play/pause state changes
      if (mounted) setState(() {}); // Trigger rebuilds for play/pause state changes
      if (controller.isPlaying && !_hasStarted) {
        _hasStarted = true;
        HapticService.selection();
        HapticService.selection();
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

  Future<void> _checkFirstSession() async {
    final completed = await FirstLaunchService.instance.hasCompletedFirstSession();
    if (mounted) {
      setState(() => _isFirstSession = !completed);
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      QuietDebugActions.instance.unregisterAction('Skip Session');
    }
    if (kDebugMode) {
      QuietDebugActions.instance.unregisterAction('Skip Session');
    }
    _countdownTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleSessionComplete() async {
    if (!mounted) return;

    // Check streak to decide which results screen to show
    final currentStreak = await QuietStreakService.getCurrentStreak();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuietResultsOkScreen(
          previousStreak: widget.streak, // original streak passed into screen
          streak: currentStreak,
          completedToday: true,
          isNew: currentStreak == 1 && widget.streak == 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxHeight = constraints.maxHeight;
            const double circleRadius = (kQBCircleSize / 2) + kQBRingOuterPadding + kQBRingThickness;
            final double centerY = maxHeight / 2;
            final double circleTopY = centerY - circleRadius;
            final double circleBottomY = centerY + circleRadius;
            
            // Top bar height is 64
            const double topBarHeight = 64.0;
            
            return Stack(
              children: [
                // 1. CENTERED BREATHING CIRCLE (Geometric center of device)
                Center(
                  child: QuietBreathCircle(controller: controller),
                ),

                // 2. TIMER TITLE (Positioned relative to the circle)
                Positioned(
                  top: topBarHeight,
                  left: 0,
                  right: 0,
                  height: circleTopY - topBarHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedBuilder(
                        animation: controller.listenable,
                        builder: (_, _) => QuietBreathTimerTitle(controller: controller),
                      ),
                    ),
                  ),
                ),

                // 3. CONSOLIDATED TOP ROW
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopRow(),
                ),

                // 4. CONTROLS (Positioned relative to the circle bottom)
                Positioned(
                  top: circleBottomY,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
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
                ),

                // COUNTDOWN OVERLAY
                if (_countdownValue != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(_countdownValue),
                          tween: Tween(begin: 1.5, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: (value - 0.5).clamp(0.0, 1.0),
                                child: Text(
                                  '$_countdownValue',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 80,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 64, // Sufficient height for the top row
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildLeftControls(),
          ),
          Align(
            alignment: Alignment.center,
            child: _buildPracticeSelector(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildRightControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftControls() {
    // PRE-SESSION BACK BUTTON
    if (!_hasStarted && _countdownValue == null) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: 22,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Go back',
        splashRadius: 24,
      );
    }

    // IN-SESSION PAUSE/PLAY + MUTE
    if (_showPauseIcon && _countdownValue == null) {
      return AnimatedOpacity(
        opacity: _showPauseIcon ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: controller.listenable,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Play/Pause
              // 1. Play/Pause
              IconButton(
                icon: Icon(
                  controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  HapticService.selection();
                  HapticService.selection();
                  controller.toggle();
                },
              ),
              const SizedBox(width: 4),
              
              // 2. Mute/Unmute
              
              // 2. Mute/Unmute
              ListenableBuilder(
                listenable: SoundscapeService.instance,
                builder: (context, _) {
                  final isMuted = SoundscapeService.instance.isMuted;
                  return IconButton(
                    icon: Icon(
                      isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      HapticService.selection();
                      HapticService.selection();
                      SoundscapeService.instance.toggleMute();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRightControls() {
    final showCancel = !_isFirstSession && !controller.isPlaying && _hasStarted && _countdownValue == null;

    return AnimatedOpacity(
      opacity: showCancel ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !showCancel,
        child: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          onPressed: () {
            HapticService.light();
            _handleCancel();
          },
          tooltip: 'End session',
        ),
      ),
    final showCancel = !_isFirstSession && !controller.isPlaying && _hasStarted && _countdownValue == null;

    return AnimatedOpacity(
      opacity: showCancel ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !showCancel,
        child: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          onPressed: () {
            HapticService.light();
            _handleCancel();
          },
          tooltip: 'End session',
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
            HapticService.light();
            HapticService.light();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QuietPracticeLibraryScreen()),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACTIVE PRACTICE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  practiceName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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