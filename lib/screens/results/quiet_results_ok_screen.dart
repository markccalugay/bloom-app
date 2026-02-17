import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_model.dart';
import 'package:quietline_app/widgets/monetization/quiet_inline_unlock_card.dart';
import 'package:quietline_app/screens/practices/quiet_practice_library_screen.dart';

import 'package:quietline_app/core/services/mood_service.dart';
import 'quiet_results_constants.dart';
import 'quiet_results_strings.dart';
import 'widgets/quiet_results_streak_badge.dart';
import 'widgets/quiet_results_streak_row.dart';
import 'package:quietline_app/core/services/haptic_service.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/core/app_assets.dart';
import 'package:quietline_app/core/backup/backup_coordinator.dart';
import 'package:quietline_app/core/services/quiet_debug_actions.dart';
import 'package:quietline_app/core/services/quiet_logger.dart';
import 'package:flutter/foundation.dart';

/// “You showed up again” results screen shown when mood >= 3.
///
/// IMPORTANT: The streak animation should start only after this screen is
/// fully on-screen (post-frame), so the user actually sees it.
class QuietResultsOkScreen extends StatefulWidget {
  final int streak;

  /// Previous streak value BEFORE this results screen.
  /// If provided, we'll compute whether the streak increased.
  final int? previousStreak;

  /// Backwards-compat: older call sites may still pass this.
  /// Prefer passing `previousStreak`.
  final bool isNew; // pass true when streak just increased

  /// Whether the user has completed a quiet session today (data-layer signal).
  final bool completedToday;

  const QuietResultsOkScreen({
    super.key,
    required this.streak,
    this.previousStreak,
    this.isNew = false,
    this.completedToday = true,
  });

  @override
  State<QuietResultsOkScreen> createState() => _QuietResultsOkScreenState();
}

class _QuietResultsOkScreenState extends State<QuietResultsOkScreen>
    with SingleTickerProviderStateMixin {
  // Sequence orchestration
  bool _shouldAnimateStreak = false; // global gate (screen is ready)
  bool _animateRow = false;          // small flames step
  bool _animateBadge = false;        // big flame step

  // Debug-only: allows simulating streak progression without touching persistence.
  int? _debugStreakOverride;
  int? _debugPrevOverride;

  // Forces the flame widgets to rebuild their internal animation controllers.
  int _animationSeed = 0;

  int? _selectedMood;

  // Number count-up (0 -> 1, 1 -> 2, etc)
  late final AnimationController _countController;

  // Tunable timings
  static const Duration _screenSettleDelay = Duration(milliseconds: 650);
  static const Duration _rowStartDelay = Duration(milliseconds: 200);
  static const Duration _badgeStartAfterRow = Duration(milliseconds: 850);
  static const Duration _countDuration = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: _countDuration,
    );

    if (kDebugMode) {
      QuietDebugActions.instance.registerAction('Replay Animation', () {
        QuietLogger.instance.info('Debug: Replaying streak animation...');
        _triggerAnimation();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // First frame has been painted.
      await Future.delayed(_screenSettleDelay);
      _triggerAnimation();
    });
  }

  Future<void> _triggerAnimation() async {
    if (!mounted) return;

    final int streak = _debugStreakOverride ?? widget.streak;
    final int prevStreak = (_debugPrevOverride ??
            widget.previousStreak ??
            (widget.isNew ? (streak - 1) : streak))
        .clamp(0, 999999);

    final bool streakIncreased =
        widget.previousStreak != null ? (streak > prevStreak) : widget.isNew;

    if (!streakIncreased) return;

    // Reset state for replay
    setState(() {
      _shouldAnimateStreak = true;
      _animationSeed++; // rebuild children so their internal controllers restart
      _animateRow = false;
      _animateBadge = false;
    });

    // Step 1: animate the small flame row first.
    await Future.delayed(_rowStartDelay);
    if (!mounted) return;
    setState(() {
      _animateRow = true;
    });

    // Step 2: after the row has had time to play, animate the badge + number.
    await Future.delayed(_badgeStartAfterRow);
    if (!mounted) return;
    HapticService.medium();
    setState(() {
      _animateBadge = true;
    });

    // Start number count-up alongside the badge slam.
    _countController.forward(from: 0.0);

    // Trigger background backup
    BackupCoordinator.instance.runBackup();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      QuietDebugActions.instance.unregisterAction('Replay Animation');
    }
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Decide if this screen represents a newly earned session.
    final int totalSessions = widget.streak;
    final int prevTotalSessions = widget.previousStreak ?? (widget.isNew ? (totalSessions - 1) : totalSessions);
    final bool sessionIncreased = widget.completedToday;
    final bool continuedProgress = sessionIncreased && prevTotalSessions > 0;
    final bool showPracticeUnlock = sessionIncreased && totalSessions >= 3;
    
    // Compute displaySessionsNow for the Session X label.
    int displaySessionsNow;
    if (!_shouldAnimateStreak || !_animateBadge) {
      displaySessionsNow = math.max(1, prevTotalSessions);
    } else {
      final t = _countController.value;
      final eased = Curves.easeOutCubic.transform(t);
      displaySessionsNow = (prevTotalSessions +
              ((totalSessions - prevTotalSessions) * eased).round())
          .clamp(1, math.max(1, totalSessions));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QuietResultsConstants.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
  
                // Headline (centered)
                Text(
                  QuietResultsStrings.okHeadline,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
  
                const SizedBox(height: 8),
  
                // Subcopy (centered)
                Text(
                  QuietResultsStrings.okSub,
                  style: textTheme.bodyMedium?.copyWith(
                    color: (textTheme.bodyMedium?.color ?? Colors.white)
                        .withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.left,
                ),
  
                const SizedBox(height: 48), // Reduced from 80
  
                // Center block: day label, big flame, small flames
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Day X of your quiet streak (updated to use displayStreakNow)
                      Text(
                        QuietResultsStrings.dayOfStreak(displaySessionsNow),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
  
                      const SizedBox(
                        height: QuietResultsConstants.verticalSpacingMedium,
                      ),
  
                      // Big SVG flame badge
                      AnimatedBuilder(
                        animation: _countController,
                        builder: (context, _) {
                          int currentDisplay;
                          if (!sessionIncreased) {
                            currentDisplay = totalSessions;
                          } else if (!_shouldAnimateStreak || !_animateBadge) {
                            currentDisplay = prevTotalSessions;
                          } else {
                            final t = _countController.value;
                            final eased = Curves.easeOutCubic.transform(t);
                            currentDisplay = (prevTotalSessions + ((totalSessions - prevTotalSessions) * eased).round()).clamp(prevTotalSessions, totalSessions);
                          }
  
                          final bool badgeShouldAnimate = sessionIncreased && _shouldAnimateStreak && _animateBadge;
                          final int badgePreviousCount = continuedProgress ? totalSessions : prevTotalSessions;
                          
                          return QuietResultsStreakBadge(
                            key: ValueKey('session_badge_$_animationSeed'),
                            // IMPORTANT: drive the badge's visual state from the displayed value so it
                            // starts inactive (gray) on FTUE and only turns teal when the count-up begins.
                            streak: currentDisplay,
                            previousStreak: badgePreviousCount,
                            // the badge renders this number (0->1, 1->2, etc)
                            displayStreak: currentDisplay,
                            // Badge only animates in step 2
                            animate: badgeShouldAnimate,
                            // badge should start immediately when step 2 flips true
                            startDelay: Duration.zero,
                            // Prevent teal -> gray -> teal flicker on continued streak days.
                            // For continued streaks, treat the badge as already active by setting
                            // its previousStreak equal to the current streak.
                            startInactive: !continuedProgress,
                            // Play wiggle only on continued streaks (no color transition)
                            wiggleOnly: continuedProgress,
                            completedToday: sessionIncreased
                                ? (_shouldAnimateStreak && _animateBadge)
                                : widget.completedToday,
                          );
                        },
                      ),
  
                      const SizedBox(
                        height: QuietResultsConstants.verticalSpacingSmall,
                      ),
  
                      // Small flame row
                      QuietResultsStreakRow(
                        key: ValueKey('session_row_$_animationSeed'),
                        streak: (!sessionIncreased)
                            ? totalSessions
                            : ((_shouldAnimateStreak && _animateRow) ? totalSessions : prevTotalSessions),
                        previousStreak: continuedProgress ? totalSessions : prevTotalSessions,
                        // Row only animates in step 1
                        animate: sessionIncreased && _shouldAnimateStreak && _animateRow,
                        // row starts immediately when step 1 flips true
                        startDelay: Duration.zero,
                      ),

                      const SizedBox(height: 40), // Reduced from 48

                      _buildMoodSelector(theme),
                    ],
                  ),
                ),
  
                const SizedBox(height: 48), // Reduced from 80
  
                if (showPracticeUnlock) ...[
                  QuietInlineUnlockCard(
                    title: 'You’re building momentum.',
                    subtitle:
                        'QuietLine+ Premium includes deeper practices, progress-based unlocks, and expanded affirmation libraries.',
                    ctaLabel: 'View practices',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuietPracticeLibraryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
  
  
                QLPrimaryButton(
                  label: QuietResultsStrings.continueButton,
                    onPressed: () async {
                      if (_selectedMood != null) {
                        await MoodService.instance.logMood(_selectedMood!);
                      }

                      if (sessionIncreased) {
                      final unlockService = AffirmationsUnlockService.instance;
                      await unlockService.unlockIfEligibleForToday(totalSessions);
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => QuietAffirmationUnlockedScreen(streak: totalSessions),
                        ),
                      );
                      return;
                    }
  
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const QuietShellScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  margin: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector(ThemeData theme) {
    final moods = [
      {'value': 1, 'emoji': '😔', 'label': 'Lowered'},
      {'value': 2, 'emoji': '🥱', 'label': 'Tired'},
      {'value': 3, 'emoji': '😐', 'label': 'Neutral'},
      {'value': 4, 'emoji': '😌', 'label': 'Calm'},
      {'value': 5, 'emoji': '✨', 'label': 'Balanced'},
    ];

    return Column(
      children: [
        Text(
          'How do you feel now?',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((m) {
            final isSelected = _selectedMood == m['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() {
                    _selectedMood = m['value'] as int;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        m['emoji'] as String,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        m['label'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Post-results interstitial shown only when a new session is completed.
/// It reveals the newly unlocked affirmation for that day.
class QuietAffirmationUnlockedScreen extends StatefulWidget {
  final int streak; // Renamed conceptually to total sessions in usage

  const QuietAffirmationUnlockedScreen({
    super.key,
    required this.streak,
  });

  @override
  State<QuietAffirmationUnlockedScreen> createState() =>
      _QuietAffirmationUnlockedScreenState();
}

class _QuietAffirmationUnlockedScreenState
    extends State<QuietAffirmationUnlockedScreen>
    with TickerProviderStateMixin {
  // ... (keeping internal animation controllers same)
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _flip;

  late final AnimationController _confettiController;
  late final Animation<double> _confettiProgress;
  final List<_ConfettiPiece> _confettiPieces = [];
  bool _showConfetti = false;

  bool _showContinue = false;

  late final Future<Affirmation?> _affirmationFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.02)
            .chain(CurveTween(curve: const Interval(0.0, 0.35, curve: Curves.easeOut))),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.75, 1.0, curve: Curves.easeOutBack))),
        weight: 65,
      ),
    ]).animate(_controller);

    _flip = Tween<double>(begin: 0.0, end: 3.0 * 3.141592653589793).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.90, curve: Curves.easeInOutCubic),
      ),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _confettiProgress = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    );

    final rng = math.Random(42);
    for (int i = 0; i < 44; i++) {
      _confettiPieces.add(
        _ConfettiPiece(
          x0: (rng.nextDouble() - 0.5) * 220,
          y0: (rng.nextDouble() - 0.5) * 40,
          angle: rng.nextDouble() * math.pi * 2,
          speed: 160 + rng.nextDouble() * 220,
          size: 4 + rng.nextDouble() * 6,
          spin: (rng.nextDouble() - 0.5) * 10,
          color: i % 7 == 0
              ? const Color(0xFF3E8F87)
              : Colors.white.withValues(alpha: 0.9),
        ),
      );
    }

    _affirmationFuture =
        AffirmationsUnlockService.instance.getUnlockedForStreak(widget.streak);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showConfetti = true);
        _confettiController.forward(from: 0.0).whenComplete(() {
          if (!mounted) return;
          setState(() => _showConfetti = false);
        });

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() => _showContinue = true);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      HapticService.light();
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        HapticService.medium();
      });
      Future.delayed(const Duration(milliseconds: 1180), () {
        if (!mounted) return;
        HapticService.heavy();
      });

      Future<void>.delayed(const Duration(milliseconds: 880), () {
        if (!mounted) return;
        SoundscapeService.instance.playSfx(AppAssets.affirmationRevealSfx);
      });

      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatMonthDayYear(DateTime now) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[now.month - 1];
    return '$month ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final unlockedLabel =
        'Unlocked on Day ${widget.streak} ${_formatMonthDayYear(DateTime.now())}';


    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QuietResultsConstants.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                'New affirmation unlocked',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                unlockedLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: (textTheme.bodyMedium?.color ?? Colors.white)
                      .withValues(alpha: 0.85),
                ),
              ),

              const Spacer(),

              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: FutureBuilder<Affirmation?>(
                        future: _affirmationFuture,
                        builder: (context, snapshot) {
                          final affirmationText =
                              snapshot.data?.text ?? 'You showed up today.';

                          // Wiggle during the first 35%.
                          final t = _controller.value;
                          final wigglePhase = (t <= 0.35) ? (t / 0.35) : 0.0;
                          final wiggle = (wigglePhase == 0.0)
                              ? 0.0
                              : (0.06 * (1.0 - wigglePhase) *
                                  math.sin(wigglePhase * 14.0));

                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              final flip = _flip.value;

                              // Normalize to [0, 2π) so front/back decision stays correct across multiple flips.
                              const twoPi = 2.0 * 3.141592653589793;
                              final normalized = flip % twoPi;
                              final showFront =
                                  (normalized <= 1.5707963267948966) ||
                                      (normalized >= 4.71238898038469);

                              final front = _AffirmationUnlockCard(
                                title: 'Unlocked',
                                subtitle: unlockedLabel,
                                body: null,
                                isFront: true,
                              );

                              final back = _AffirmationUnlockCard(
                                title: 'Unlocked',
                                subtitle: unlockedLabel,
                                body: affirmationText,
                                isFront: false,
                              );

                              // “Slam” at the end: quick punch + settle.
                              final t = _controller.value;
                              double slamScale = 1.0;
                              double slamRotateZ = 0.0;
                              double slamTranslateY = 0.0;
                              if (t > 0.85) {
                                final p = ((t - 0.85) / 0.15).clamp(0.0, 1.0);
                                // Ease in then slight overshoot back.
                                final punch = Curves.easeInOut.transform(p);
                                slamScale = 1.0 - (0.06 * punch);
                                // slamRotateZ = -0.02 * punch; // REMOVE tilt so card ends straight
                                slamTranslateY = 10.0 * punch;
                              }

                              final card = showFront
                                  ? front
                                  // Rotate the back by π so text is readable (not mirrored)
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(3.141592653589793),
                                      child: back,
                                    );

                              final transformedCard = Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0015)
                                  ..translateByDouble(0.0, slamTranslateY, 0.0, 1.0)
                                  ..scaleByDouble(slamScale, slamScale, slamScale, 1.0)
                                  ..rotateZ(wiggle + slamRotateZ)
                                  ..rotateY(flip),
                                child: card,
                              );

                              return Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  transformedCard,
                                  if (_showConfetti)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: AnimatedBuilder(
                                          animation: _confettiProgress,
                                          builder: (context, _) {
                                            return CustomPaint(
                                              painter: _ConfettiPainter(
                                                progress: _confettiProgress.value,
                                                pieces: _confettiPieces,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _showContinue
                    ? QLPrimaryButton(
                        label: QuietResultsStrings.continueButton,
                        onPressed: () async {
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const QuietShellScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        margin: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                          bottom: 32,
                        ),
                      )
                    : const SizedBox(height: 72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AffirmationUnlockCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? body;
  final bool isFront;

  const _AffirmationUnlockCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final Color textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.brightness == Brightness.dark
            ? theme.cardColor.withValues(alpha: 0.18)
            : theme.colorScheme.surface.withValues(alpha: 0.90),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.10)
              : theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 12),
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.22 : 0.08),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small header row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFront ? Icons.lock_open_rounded : Icons.auto_awesome_rounded,
                size: 18,
                color: textColor.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: textColor.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.72),
              height: 1.2,
            ),
          ),

          const SizedBox(height: 18),

          // Front: teaser. Back: actual affirmation.
          Text(
            body ?? 'Tap into stillness.',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
// Confetti helpers

class _ConfettiPiece {
  final double x0;
  final double y0;
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final Color color;

  const _ConfettiPiece({
    required this.x0,
    required this.y0,
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress; // 0..1
  final List<_ConfettiPiece> pieces;

  _ConfettiPainter({
    required this.progress,
    required this.pieces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Simple physics.
    final t = progress;
    final gravity = 520.0;

    for (final p in pieces) {
      final vx = math.cos(p.angle) * p.speed;
      final vy = math.sin(p.angle) * p.speed;

      // Emit from center-ish of the card area.
      final x = center.dx + p.x0 + vx * t;
      final y = center.dy + p.y0 + vy * t + 0.5 * gravity * t * t;

      // Fade out near the end.
      final alpha = (1.0 - t).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      // Spin as it falls.
      final rotation = p.spin * t;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 1.4,
          height: p.size,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pieces != pieces;
  }
}