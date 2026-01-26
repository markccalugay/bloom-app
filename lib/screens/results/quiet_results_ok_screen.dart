import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_model.dart';
import 'package:quietline_app/widgets/monetization/quiet_inline_unlock_card.dart';
import 'package:quietline_app/screens/practices/quiet_practice_library_screen.dart';

import 'quiet_results_constants.dart';
import 'quiet_results_strings.dart';
import 'widgets/quiet_results_streak_badge.dart';
import 'widgets/quiet_results_streak_row.dart';

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
  bool _debugForceAnimate = false;

  // Debug-only: allows simulating streak progression without touching persistence.
  int? _debugStreakOverride;
  int? _debugPrevOverride;

  // Forces the flame widgets to rebuild their internal animation controllers.
  int _animationSeed = 0;

  // Prevents auto-play from retriggering on rebuilds.
  bool _didAutoPlay = false;

  // Number count-up (0 -> 1, 1 -> 2, etc)
  late final AnimationController _countController;
  int _countFrom = 0;
  int _countTo = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // First frame has been painted.
      await Future.delayed(_screenSettleDelay);
      if (!mounted) return;

      final int streak = _debugStreakOverride ?? widget.streak;
      final int prevStreak = (_debugPrevOverride ?? widget.previousStreak ?? (widget.isNew ? (streak - 1) : streak))
          .clamp(0, 999999);

      final bool streakIncreased = widget.previousStreak != null
          ? (streak > prevStreak)
          : widget.isNew;

      if (!streakIncreased) return;
      if (_didAutoPlay) return;

      _didAutoPlay = true;

      // Gate opens: this screen is fully visible.
      if (!mounted) return;
      setState(() {
        _shouldAnimateStreak = true;
        _animationSeed++; // rebuild children so their internal controllers restart

        // Sequence state
        _animateRow = false;
        _animateBadge = false;

        // Count-up config
        _countFrom = prevStreak;
        _countTo = streak;
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
      setState(() {
        _animateBadge = true;
      });

      // Start number count-up alongside the badge slam.
      _countController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Decide if this screen represents a newly earned streak day.
    // - Prefer comparing against `previousStreak` when available.
    // - Fall back to `isNew` for older callers.
    // - FTUE safety: if someone forgets to pass flags on Day 1, we still animate.
    final int streak = _debugStreakOverride ?? widget.streak;
    final int prevStreak =
        (_debugPrevOverride ?? widget.previousStreak ?? (widget.isNew ? (streak - 1) : streak))
            .clamp(0, 999999);
    final bool streakIncreased = widget.previousStreak != null
        ? (streak > prevStreak)
        : widget.isNew;
    final bool continuedStreak = streakIncreased && prevStreak > 0;
    final bool showPracticeUnlock = streakIncreased && streak >= 3;

    // Compute displayStreakNow for the Day X label.
    // This must never show Day 0 and must match the big flame number.
    int displayStreakNow;
    if (!streakIncreased) {
      displayStreakNow = math.max(1, streak);
    } else if (!_shouldAnimateStreak || !_animateBadge) {
      displayStreakNow = math.max(1, prevStreak);
    } else {
      final t = _countController.value;
      final eased = Curves.easeOutCubic.transform(t);
      displayStreakNow = (_countFrom +
              ((_countTo - _countFrom) * eased).round())
          .clamp(1, _countTo);
    }

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

              const Spacer(),

              // Center block: day label, big flame, small flames
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day X of your quiet streak (updated to use displayStreakNow)
                    Text(
                      QuietResultsStrings.dayOfStreak(displayStreakNow),
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
                        int displayStreak;
                        if (!streakIncreased) {
                          displayStreak = streak;
                        } else if (!_shouldAnimateStreak || !_animateBadge) {
                          displayStreak = prevStreak;
                        } else {
                          final t = _countController.value;
                          final eased = Curves.easeOutCubic.transform(t);
                          displayStreak = (_countFrom + ((_countTo - _countFrom) * eased).round()).clamp(_countFrom, _countTo);
                        }

                        final bool badgeShouldAnimate =
                            (_debugForceAnimate || streakIncreased) && _shouldAnimateStreak && _animateBadge;
                        // Prevent teal -> gray -> teal flicker on continued streak days.
                        // For continued streaks, treat the badge as already active by setting
                        // its previousStreak equal to the current streak.
                        final int badgePreviousStreak = continuedStreak ? streak : prevStreak;
                        return QuietResultsStreakBadge(
                          key: ValueKey('streak_badge_$_animationSeed'),
                          // IMPORTANT: drive the badge's visual state from the displayed value so it
                          // starts inactive (gray) on FTUE and only turns teal when the count-up begins.
                          streak: displayStreak,
                          previousStreak: badgePreviousStreak,
                          // the badge renders this number (0->1, 1->2, etc)
                          displayStreak: displayStreak,
                          // Badge only animates in step 2
                          animate: badgeShouldAnimate,
                          // badge should start immediately when step 2 flips true
                          startDelay: Duration.zero,
                          // Prevent gray->teal on continued streaks, only FTUE
                          startInactive: !continuedStreak,
                          // Play wiggle only on continued streaks (no color transition)
                          wiggleOnly: continuedStreak,
                          completedToday: streakIncreased
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
                      key: ValueKey('streak_row_$_animationSeed'),
                      streak: (!streakIncreased)
                          ? streak
                          : ((_shouldAnimateStreak && _animateRow) ? streak : prevStreak),
                      previousStreak: continuedStreak ? streak : prevStreak,
                      // Row only animates in step 1
                      animate: (_debugForceAnimate || streakIncreased) && _shouldAnimateStreak && _animateRow,
                      // row starts immediately when step 1 flips true
                      startDelay: Duration.zero,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (showPracticeUnlock) ...[
                QuietInlineUnlockCard(
                  title: 'Explore deeper practices',
                  subtitle:
                      'Go beyond the core reset with guided discipline, calm, and resilience practices.',
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

              // DEBUG BUTTONS (TEMPORARY)
              if (kDebugMode) ...[
                TextButton(
                  onPressed: () async {
                    final int streak = _debugStreakOverride ?? widget.streak;
                    final int prevStreak = (_debugPrevOverride ?? widget.previousStreak ?? (widget.isNew ? (streak - 1) : streak))
                        .clamp(0, 999999);

                    setState(() {
                      _debugForceAnimate = true;
                      _shouldAnimateStreak = true;

                      // reset sequence
                      _animateRow = false;
                      _animateBadge = false;

                      // reset number
                      _countFrom = prevStreak;
                      _countTo = streak;
                      _countController.stop();
                      _countController.value = 0.0;

                      // restart child controllers
                      _animationSeed++;
                    });

                    // Row first
                    await Future.delayed(_rowStartDelay);
                    if (!mounted) return;
                    setState(() => _animateRow = true);

                    // Badge second
                    await Future.delayed(_badgeStartAfterRow);
                    if (!mounted) return;
                    setState(() => _animateBadge = true);

                    _countController.forward(from: 0.0);
                  },
                  child: const Text(
                    'DEBUG: Play Streak Animation',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    final int current = _debugStreakOverride ?? widget.streak;
                    final int next = (current + 1).clamp(0, 999999);

                    setState(() {
                      _debugForceAnimate = true;
                      _shouldAnimateStreak = true;

                      // Simulate a clean day-to-day increment
                      _debugPrevOverride = current;
                      _debugStreakOverride = next;

                      // reset sequence
                      _animateRow = false;
                      _animateBadge = false;

                      // number animation
                      _countFrom = current;
                      _countTo = next;
                      _countController.stop();
                      _countController.value = 0.0;

                      // restart child controllers
                      _animationSeed++;
                    });

                    // Row first
                    await Future.delayed(_rowStartDelay);
                    if (!mounted) return;
                    setState(() => _animateRow = true);

                    // Badge second
                    await Future.delayed(_badgeStartAfterRow);
                    if (!mounted) return;
                    setState(() => _animateBadge = true);

                    _countController.forward(from: 0.0);
                  },
                  child: const Text(
                    'DEBUG: Next Day (+1)',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      // Reset to FTUE scenario: 0 -> 1
                      _debugPrevOverride = 0;
                      _debugStreakOverride = 1;

                      _debugForceAnimate = false;
                      _shouldAnimateStreak = false;
                      _animateRow = false;
                      _animateBadge = false;

                      _countController.stop();
                      _countController.value = 0.0;

                      _animationSeed++;
                      _didAutoPlay = false;
                    });
                  },
                  child: const Text(
                    'DEBUG: Reset FTUE (0→1)',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],

              // Bottom primary button, matching design
              QLPrimaryButton(
                label: QuietResultsStrings.continueButton,
                onPressed: () async {
                  if (streakIncreased) {
                    final unlockService = AffirmationsUnlockService.instance;
                    await unlockService.unlockIfEligibleForToday(streak);
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuietAffirmationUnlockedScreen(streak: streak),
                      ),
                    );
                    return;
                  }

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
    );
  }
}

/// Post-results interstitial shown only when a new streak day is earned.
/// It reveals the newly unlocked affirmation for that day.
class QuietAffirmationUnlockedScreen extends StatefulWidget {
  final int streak;

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

    // Slight pop at the end (the "burst")
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

    // Card flip reveal: 3 full flips (0 -> 3π) between 35% and 85%.
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

    // Pre-generate confetti pieces (stable, deterministic).
    final rng = math.Random(42);
    for (int i = 0; i < 44; i++) {
      _confettiPieces.add(
        _ConfettiPiece(
          // Emit from roughly the card center.
          x0: (rng.nextDouble() - 0.5) * 220,
          y0: (rng.nextDouble() - 0.5) * 40,
          angle: rng.nextDouble() * math.pi * 2,
          speed: 160 + rng.nextDouble() * 220,
          size: 4 + rng.nextDouble() * 6,
          spin: (rng.nextDouble() - 0.5) * 10,
          // Keep colors on-brand: mostly white with a hint of teal.
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
        // Confetti burst after the card finishes the slam.
        setState(() => _showConfetti = true);
        _confettiController.forward(from: 0.0).whenComplete(() {
          if (!mounted) return;
          setState(() => _showConfetti = false);
        });

        // Give the user a moment to read before showing Continue.
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() => _showContinue = true);
        });
      }
    });

    // Start animation on first frame, card renders immediately, then dwell before flip/twirl.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 1180), () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
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
                        onPressed: () {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.cardColor.withValues(alpha: 0.18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 12),
            color: Colors.black.withValues(alpha: 0.22),
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
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
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
              color: Colors.white,
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