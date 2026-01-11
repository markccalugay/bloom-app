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

  const QuietResultsStreakBadge({
    super.key,
    required this.streak,
    this.previousStreak,
    this.animate = true,
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

  late final LinearGradientTween _gradientTween;

  bool get _isActive => widget.streak > 0;

  bool get _shouldAnimate {
    if (!widget.animate) return false;
    if (widget.previousStreak == null) return false;

    return widget.streak > widget.previousStreak!;
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );

    _gradientT = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _gradientTween = LinearGradientTween(
      begin: QuietResultsConstants.inactiveGradient,
      end: QuietResultsConstants.streakGradient as LinearGradient,
    );

    if (_shouldAnimate) {
      _animController.forward(from: 0);
    } else {
      _animController.value = _isActive ? 1.0 : 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant QuietResultsStreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldAnimate) {
      _animController.forward(from: 0);
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

              return Transform.scale(
                scale: _scale.value,
                child: ShaderMask(
                  shaderCallback: (bounds) => gradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: SvgPicture.asset(
                    AppAssets.flame,
                    width: QuietResultsConstants.streakBadgeSize,
                    height: QuietResultsConstants.streakBadgeSize,
                  ),
                ),
              );
            },
          ),

          // Streak number
          Transform.translate(
            offset: const Offset(0, 6),
            child: Text(widget.streak.toString(), style: textStyle),
          ),
        ],
      ),
    );
  }
}
