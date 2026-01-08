import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../quiet_results_constants.dart';
import 'package:quietline_app/core/app_assets.dart';

/// Big central streak badge with the day number.
/// Uses the flame SVG + a teal gradient via ShaderMask when active.
class QuietResultsStreakBadge extends StatelessWidget {
  final int streak;
  final bool isNew; // reserved for future animation use

  const QuietResultsStreakBadge({
    super.key,
    required this.streak,
    this.isNew = false,
  });

  bool get _isActive => streak > 0;

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
          // Flame SVG background
          if (_isActive)
            ShaderMask(
              shaderCallback: (bounds) =>
                  QuietResultsConstants.streakGradient.createShader(bounds),
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
            child: Text(streak.toString(), style: textStyle),
          ),
        ],
      ),
    );
  }
}
