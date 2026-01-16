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
    final int prev = (prevRaw >= streak) ? (streak - 1) : prevRaw;
    final int prevClamped = prev < 0 ? 0 : prev;

    // FTUE: show 3 flames initially. After Day 3 is reached, expand to 5.
    // Keep this widget future-proof by still allowing a caller-provided maxFlames
    // to cap the display.
    final int targetFlames = streak >= 3 ? 5 : 3;
    final int effectiveMaxFlames = maxFlames < targetFlames ? maxFlames : targetFlames;

    final bool didIncrement = animate && (streak > prevClamped);
    final bool isCapped = prevClamped >= effectiveMaxFlames;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(effectiveMaxFlames, (index) {
        // Streak step labels: 1,2,3,... (up to maxFlames)
        final step = index + 1;
        final isActive = streak >= step;

        // Newly earned if it crossed this step during this session.
        final animateIn = animate && isActive && prevClamped < step;

        final bool wiggleOnly = didIncrement && isCapped && index == effectiveMaxFlames - 1;

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
                  const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF5E6874),
                      Color(0xFF313841),
                    ],
                  ).createShader(bounds),
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
