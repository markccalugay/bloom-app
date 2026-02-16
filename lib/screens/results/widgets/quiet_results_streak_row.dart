import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../quiet_results_constants.dart';
import 'package:quietline_app/core/app_assets.dart';

/// Small flame streak row.
///
/// Flames represent consecutive days in the current streak (1..maxFlames).
/// A flame is active if `streak >= (index + 1)`.
///
/// This is future-proof: bump [maxFlames] as needed (e.g., 3 -> 5).
class QuietResultsStreakRow extends StatelessWidget {
  final int streak;

  /// Used only to animate newly-earned flames.
  /// Pass the streak value from before the session completed.
  final int? previousStreak;

  /// Whether to animate newly-earned flames.
  final bool animate;

  /// Optional delay before the first flame begins animating.
  /// Useful when the results screen needs to settle before playing the sequence.
  final Duration startDelay;

  /// Number of flames shown.
  final int maxFlames;

  const QuietResultsStreakRow({
    super.key,
    required this.streak,
    this.previousStreak,
    this.animate = false,
    this.startDelay = Duration.zero,
    this.maxFlames = 5,
  });

  @override
  Widget build(BuildContext context) {
    // Be forgiving: if the caller accidentally passes the same value for
    // previousStreak and streak, we still want newly-earned flames to animate.
    // Clamp to 0 so Day 1 can animate from Day 0.
    final int prevRaw =
        (previousStreak == null) ? (streak - 1) : previousStreak!;
    // Tiered Progression Logic

    // Tier 1: Days 1-3 (3 flames)
    // Tier 2: Days 4-8 (5 flames)
    // Tier 3+: Days 9... (7 flames, resetting every 7 days)
    
    int setSize;
    int activeCount;
    
    if (streak <= 3) {
      setSize = 3;
      activeCount = streak;
    } else if (streak <= 8) {
      setSize = 5;
      activeCount = streak - 3;
    } else {
      setSize = 7;
      final relative = streak - 8;
      activeCount = ((relative - 1) % 7) + 1;
    }

    final int effectiveMaxFlames = setSize;
    final int currentStreakInTier = activeCount;

    // To handle animations (prevClamped represents the old streak position in the tier)
    int prevActiveCount;
    if (prevRaw <= 3) {
      // If we were in Tier 1
      prevActiveCount = (streak <= 3) ? prevRaw : 3;
    } else if (prevRaw <= 8) {
      // If we were in Tier 2
      prevActiveCount = (streak <= 8) ? (prevRaw - 3) : 5;
    } else {
      // If we were in Tier 3+
      final prevRelative = prevRaw - 8;
      final prevWeekNum = ((prevRelative - 1) / 7).floor();
      final currentRelative = streak - 8;
      final currentWeekNum = ((currentRelative - 1) / 7).floor();
      
      if (prevWeekNum < currentWeekNum) {
        // We crossed a week boundary, treat old week as full for animation prep
        prevActiveCount = 7;
      } else {
        prevActiveCount = ((prevRelative - 1) % 7) + 1;
      }
    }
    
    final bool didIncrement = animate && (streak > prevRaw);
    // Boundary crossing detection: if the set just filled or we are at the start of a new set
    final bool isCrossingTier = (prevActiveCount == 0 && currentStreakInTier == 1) || (prevRaw > 0 && _isSetBoundary(prevRaw));
    
    final int animationStartStep = isCrossingTier ? 0 : prevActiveCount;


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(effectiveMaxFlames, (index) {
        // Streak step labels: 1,2,3,... (up to maxFlames)
        final step = index + 1;
        final isActive = currentStreakInTier >= step;

        // Newly earned if it crossed this step during this session.
        final animateIn = animate && isActive && animationStartStep < step;

        final bool wiggleOnly = didIncrement && !isCrossingTier && isActive && index == animationStartStep;


        // Stagger each newly-earned flame.
        final delay = startDelay + Duration(milliseconds: 120 * index);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: _SmallFlame(
            label: step.toString(),
            isActive: isActive,
            animateIn: animateIn,
            delay: delay,
            wiggleOnly: wiggleOnly,
          ),
        );
      }),
    );
  }

  bool _isSetBoundary(int s) {
    if (s == 3 || s == 8) return true;
    if (s > 8) return (s - 8) % 7 == 0;
    return false;
  }
}


class _SmallFlame extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool animateIn;
  final Duration delay;
  final bool wiggleOnly;

  const _SmallFlame({
    required this.label,
    required this.isActive,
    required this.animateIn,
    required this.delay,
    this.wiggleOnly = false,
  });

  @override
  State<_SmallFlame> createState() => _SmallFlameState();
}

class _SmallFlameState extends State<_SmallFlame> with SingleTickerProviderStateMixin {
  bool _showActive = false;
  AnimationController? _revealController;

  @override
  void initState() {
    super.initState();

    if (widget.wiggleOnly) {
      _showActive = widget.isActive;
      _revealController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      );
      Future.delayed(widget.delay, () {
        if (!mounted) return;
        _revealController!.forward(from: 0.0);
      });
      return;
    }

    // If we're not animating-in, show immediately.
    if (!widget.isActive || !widget.animateIn) {
      _showActive = widget.isActive;
      return;
    }

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // Staggered reveal for newly-earned flame.
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      setState(() {
        _showActive = true;
      });
      _revealController!.forward(from: 0.0);
    });
  }

  @override
  void didUpdateWidget(covariant _SmallFlame oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.wiggleOnly && widget.wiggleOnly) {
      _revealController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 520),
      );
      Future.delayed(widget.delay, () {
        if (!mounted) return;
        _revealController!.forward(from: 0.0);
      });
    }

    // If a flame becomes newly active later, animate it in.
    final becameActive = !oldWidget.isActive && widget.isActive;
    if (becameActive) {
      if (!widget.animateIn) {
        _showActive = true;
      } else {
        _revealController ??= AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 520),
        );

        _showActive = false;
        Future.delayed(widget.delay, () {
          if (!mounted) return;
          setState(() {
            _showActive = true;
          });
          _revealController!.forward(from: 0.0);
        });
      }
    }

    // If it becomes inactive (shouldn't normally happen), keep state consistent.
    if (oldWidget.isActive && !widget.isActive) {
      _showActive = false;
    }
  }

  @override
  void dispose() {
    _revealController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white.withValues(alpha: widget.isActive ? 1.0 : 0.55),
      fontWeight: FontWeight.w600,
    );

    final showTeal = widget.isActive && _showActive;

    Widget flame = SizedBox(
      width: QuietResultsConstants.smallFlameSize,
      height: QuietResultsConstants.smallFlameSize,
      child: showTeal
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  QuietResultsConstants.streakGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: SvgPicture.asset(AppAssets.flame),
            )
          : ShaderMask(
              shaderCallback: (bounds) =>
                  QuietResultsConstants.inactiveGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: SvgPicture.asset(AppAssets.flame),
            ),
    );

    // Pop/fade when a newly-earned flame appears.
    if ((widget.animateIn && widget.isActive) || widget.wiggleOnly) {
      if (widget.animateIn && widget.isActive) {
        flame = AnimatedScale(
          scale: showTeal ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: showTeal ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            child: flame,
          ),
        );
      }
      // Wiggle during the reveal so the flame feels "earned".
      flame = AnimatedBuilder(
        animation: _revealController ?? kAlwaysDismissedAnimation,
        builder: (context, child) {
          final t = _revealController?.value ?? 0.0;
          // Wiggle decays as the animation finishes.
          final wiggle = 0.12 * (1.0 - t) * math.sin(t * 18.0);
          return Transform.rotate(
            angle: wiggle,
            child: child,
          );
        },
        child: flame,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        flame,
        const SizedBox(height: 4),
        Text(widget.label, style: textStyle),
      ],
    );
  }
}
