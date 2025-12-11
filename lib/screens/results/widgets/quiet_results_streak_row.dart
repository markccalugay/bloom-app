import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../quiet_results_constants.dart';
import 'package:quietline_app/core/app_assets.dart';

class QuietResultsStreakRow extends StatelessWidget {
  final int streak;

  const QuietResultsStreakRow({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    // We show three small tokens in a repeating 3-day mini-streak.
    // If streak <= 0: no active flames.
    // Otherwise: activeCount cycles 1 → 2 → 3 → 1 → 2 → 3 ...
    final int activeCount;
    if (streak <= 0) {
      activeCount = 0;
    } else {
      activeCount = ((streak - 1) % 3) + 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final stepIndex = index + 1;
        final isActive = stepIndex <= activeCount;
        final label = stepIndex.toString();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: _SmallFlame(
            label: label,
            isActive: isActive,
          ),
        );
      }),
    );
  }
}

class _SmallFlame extends StatelessWidget {
  final String label;
  final bool isActive;

  const _SmallFlame({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: QuietResultsConstants.smallFlameSize,
          height: QuietResultsConstants.smallFlameSize,
          child: isActive
              ? ShaderMask(
                  shaderCallback: (bounds) =>
                      QuietResultsConstants.streakGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: SvgPicture.asset(AppAssets.flame),
                )
              : SvgPicture.asset(
                  AppAssets.flame,
                  colorFilter: const ColorFilter.mode(
                    QuietResultsConstants.inactiveFlame,
                    BlendMode.srcIn,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(label, style: textStyle),
      ],
    );
  }
}
