import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/screens/results/quiet_results_constants.dart';

/// Top-of-home streak strip: 7 mini flames + 1–7 labels.
/// This is separate from the 3-day results streak mechanic.
/// Automatically spans full screen width.
class QuietHomeStreakRow extends StatelessWidget {
  final int streak; // total days user has shown up

  const QuietHomeStreakRow({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    const totalSlots = 7;

    // Wrap streak so it cycles cleanly through 1..7.
    final activeCount = streak <= 0 ? 0 : ((streak - 1) % totalSlots) + 1;

    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.85),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day $streak Streak',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Full-width row of flames
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSlots, (index) {
              final dayNumber = index + 1;
              final isActive = dayNumber <= activeCount;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniFlame(isActive: isActive),
                  const SizedBox(height: 4),
                  Text('$dayNumber', style: labelStyle),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MiniFlame extends StatelessWidget {
  final bool isActive;

  const _MiniFlame({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: QuietResultsConstants.smallFlameSize,
      height: QuietResultsConstants.smallFlameSize,
      child: isActive
          ? ShaderMask(
              shaderCallback: (bounds) =>
                  QuietResultsConstants.streakGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: SvgPicture.asset('assets/icons/flame_icon.svg'),
            )
          : SvgPicture.asset(
              'assets/icons/flame_icon.svg',
              colorFilter: const ColorFilter.mode(
                QuietResultsConstants.inactiveFlame,
                BlendMode.srcIn,
              ),
            ),
    );
  }
}