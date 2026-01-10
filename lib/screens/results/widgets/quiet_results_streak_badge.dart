import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../quiet_results_constants.dart';
import 'package:quietline_app/core/app_assets.dart';

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
  late final AnimationController _scaleController;
  late final Animation<double> _scale;

  bool get _isActive => widget.streak > 0;

  bool get _shouldAnimate {
    if (!widget.animate) return false;
    if (widget.previousStreak == null) return false;

    return widget.streak > widget.previousStreak!;
  }

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    if (_shouldAnimate) {
      _scaleController.value = 0.0;
      _scaleController.forward();
    } else {
      _scaleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant QuietResultsStreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate only when the streak increases.
    final shouldAnimate = widget.animate &&
        widget.previousStreak != null &&
        widget.streak > widget.previousStreak!;

    if (shouldAnimate) {
      _scaleController
        ..stop()
        ..value = 0.0
        ..forward();
    } else {
      // Ensure we don't remain shrunken if the widget updates without an increase.
      _scaleController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );

    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: QuietResultsConstants.streakBadgeSize,
        height: QuietResultsConstants.streakBadgeSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Flame SVG background
            if (_isActive)
              ShaderMask(
                shaderCallback: (bounds) =>
                    QuietResultsConstants.streakGradient
                        .createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: SvgPicture.asset(
                  AppAssets.flame,
                  width: QuietResultsConstants.streakBadgeSize,
                  height: QuietResultsConstants.streakBadgeSize,
                ),
              )
            else
              SvgPicture.asset(
                AppAssets.flame,
                width: QuietResultsConstants.streakBadgeSize,
                height: QuietResultsConstants.streakBadgeSize,
                colorFilter: const ColorFilter.mode(
                  QuietResultsConstants.inactiveFlame,
                  BlendMode.srcIn,
                ),
              ),

            // Streak number
            Transform.translate(
              offset: const Offset(0, 6),
              child: Text(widget.streak.toString(), style: textStyle),
            ),
          ],
        ),
      ),
    );
  }
}
