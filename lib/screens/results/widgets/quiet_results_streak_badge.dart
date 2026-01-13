import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../quiet_results_constants.dart';
import 'package:quietline_app/core/app_assets.dart';

class LinearGradientTween extends Tween<LinearGradient> {
  LinearGradientTween({required super.begin, required super.end});

  @override
  LinearGradient lerp(double t) {
    return LinearGradient(
      begin: begin!.begin,
      end: begin!.end,
      colors: List.generate(
        begin!.colors.length,
        (i) => Color.lerp(begin!.colors[i], end!.colors[i], t)!,
      ),
    );
  }
}

/// Big central streak badge with the day number.
/// Uses the flame SVG + a teal gradient via ShaderMask when active.
class QuietResultsStreakBadge extends StatefulWidget {
  final int streak;
  final int? previousStreak; // used to detect milestone crossing
  final bool animate;

  /// Force the badge to start in the inactive (gray) state on first paint.
  /// Useful when the parent orchestrates a count-up (e.g., show 0 then animate to 1)
  /// and wants to avoid a brief teal flash before the animation begins.
  final bool startInactive;

  /// Optional delay before playing the activation animation.
  final Duration startDelay;

  /// Optional number to display (useful for counting animations).
  /// If null, the widget displays `streak`.
  final int? displayStreak;

  /// Optional explicit start value for the count-up animation.
  /// If null, we fall back to `previousStreak` (when provided).
  final int? fromStreak;

  const QuietResultsStreakBadge({
    super.key,
    required this.streak,
    this.previousStreak,
    this.animate = true,
    this.startInactive = false,
    this.startDelay = Duration.zero,
    this.displayStreak,
    this.fromStreak,
  });

  @override
  State<QuietResultsStreakBadge> createState() =>
      _QuietResultsStreakBadgeState();
}

class _QuietResultsStreakBadgeState extends State<QuietResultsStreakBadge>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;
  late final Animation<double> _gradientT;
  late final Animation<double> _glow;

  late final LinearGradientTween _gradientTween;

  /// Whether the badge should be shown as "active" (teal) at rest.
  /// Note: during orchestrated count-up (e.g. displayStreak=0 while streak=1),
  /// we intentionally start inactive and animate to active.
  bool get _isActive => widget.streak > 0;

  /// When true, we should start the badge in the inactive (gray) state even if
  /// `streak > 0`, because the UI is intentionally displaying a lower number
  /// first and we want the activation to animate on-screen.
  bool get _startInactiveForOrchestratedCount {
    if (!widget.animate) return false;

    // Explicit override from parent to avoid initial teal flash.
    if (widget.startInactive) return true;

    // If the parent is controlling the displayed number and it's behind the
    // real streak, we should start inactive and animate to active.
    final display = widget.displayStreak;
    if (display != null && display < widget.streak) return true;

    // If an explicit fromStreak is provided and it's behind the real streak,
    // we should start inactive and animate to active.
    final from = widget.fromStreak;
    if (from != null && from < widget.streak) return true;

    // Only FTUE (0 -> 1) should animate gray -> teal, not continued streaks.
    if (widget.previousStreak != null &&
        widget.streak > widget.previousStreak! &&
        widget.previousStreak == 0) {
      return true;
    }

    return false;
  }

  bool get _shouldAnimate {
    if (!widget.animate) return false;
    if (widget.previousStreak == null) return false;

    return widget.streak > widget.previousStreak!;
  }

  int get _countFrom {
    if (widget.fromStreak != null) return widget.fromStreak!;
    if (widget.previousStreak != null) return widget.previousStreak!;
    return widget.streak;
  }

  void _startAnimation() {
    final delay = widget.startDelay;

    // Always reset to the beginning so the badge starts in the inactive (gray)
    // state before animating to teal.
    _animController.value = 0.0;

    if (delay == Duration.zero) {
      _animController.forward(from: 0.0);
      return;
    }

    Future.delayed(delay, () {
      if (!mounted) return;
      _animController.forward(from: 0.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Dramatic punch: dip -> overshoot -> settle.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.90)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.90, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 32,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animController);

    // Gradient fade: hold inactive briefly, then dark -> teal.
    // This ensures the badge visibly starts in the inactive (gray) state
    // before the activation sequence kicks in.
    _gradientT = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.12, 0.70, curve: Curves.easeOutCubic),
    );

    // Glow burst: on -> off.
    _glow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 65,
      ),
    ]).animate(_animController);

    _gradientTween = LinearGradientTween(
      begin: QuietResultsConstants.inactiveGradient,
      end: QuietResultsConstants.streakGradient as LinearGradient,
    );

    if (_startInactiveForOrchestratedCount) {
      // Ensure we never paint the active (teal) state before the activation animation.
      _animController.value = 0.0;
      _startAnimation();
    } else {
      _animController.value = _isActive ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant QuietResultsStreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_startInactiveForOrchestratedCount) {
      // Prevent any intermediate active paint before we restart the sequence.
      _animController.value = 0.0;
      _startAnimation();
    } else {
      _animController.value = _isActive ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );

    return SizedBox(
      width: QuietResultsConstants.streakBadgeSize,
      height: QuietResultsConstants.streakBadgeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (_, child) {
              final gradient = _gradientTween.lerp(_gradientT.value);

              // Decaying shake so it starts dramatic then settles.
              final t = _animController.value;
              final decay = (1.0 - t).clamp(0.0, 1.0);
              final shake = 0.18 * decay * math.sin(t * 22.0 * math.pi);
              final glow = _glow.value;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(_scale.value, _scale.value, 1.0, 1.0)
                  ..rotateZ(shake),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 28 + (22 * glow),
                        spreadRadius: 2 + (6 * glow),
                        offset: const Offset(0, 10),
                        color: const Color(0xFF3E8F87)
                            .withValues(alpha: 0.22 + 0.28 * glow),
                      ),
                    ],
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => gradient.createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: SvgPicture.asset(
                      AppAssets.flame,
                      width: QuietResultsConstants.streakBadgeSize,
                      height: QuietResultsConstants.streakBadgeSize,
                    ),
                  ),
                ),
              );
            },
          ),

          // Streak number (counts up during the same animation as the flame)
          Transform.translate(
            offset: const Offset(0, 6),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, _) {
                // If an external displayStreak is provided, respect it (orchestrator-controlled).
                if (widget.displayStreak != null) {
                  return Text(widget.displayStreak!.toString(), style: textStyle);
                }

                // Default behavior: count from previous -> current while animating.
                if (_shouldAnimate) {
                  final start = _countFrom;
                  final end = widget.streak;

                  // Drive the number mostly during the first part of the animation.
                  final t = Curves.easeOutCubic.transform(
                    (_animController.value / 0.70).clamp(0.0, 1.0),
                  );

                  final value = (start + ((end - start) * t)).round();
                  return Text(value.toString(), style: textStyle);
                }

                return Text(widget.streak.toString(), style: textStyle);
              },
            ),
          ),
        ],
      ),
    );
  }
}
