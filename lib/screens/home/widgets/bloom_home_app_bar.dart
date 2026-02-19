import 'package:flutter/material.dart';
import 'package:bloom_app/core/practices/practice_access_service.dart';
import 'package:bloom_app/core/services/haptic_service.dart';

/// Simple top app bar for the Bloom Home screen.
/// Shows a hamburger menu on the left and the active practice details centered on the screen.
class BloomHomeAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onPracticeTap;
  final GlobalKey? menuKey;

  const BloomHomeAppBar({
    super.key,
    this.onMenuTap,
    this.onPracticeTap,
    this.menuKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final accessService = PracticeAccessService.instance;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
      child: SizedBox(
        width: double.infinity,
        height: 60, // Fixed height for the app bar area
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left: Menu Button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: menuKey,
                icon: const Icon(Icons.menu),
                color: color,
                onPressed: onMenuTap ?? () {},
              ),
            ),

            // Center: Active Practice
            InkWell(
              onTap: () {
                HapticService.light();
                onPracticeTap?.call();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ValueListenableBuilder<String>(
                  valueListenable: accessService.activePracticeId,
                  builder: (context, activeId, _) {
                    final practiceName = activeId.replaceAll('_', ' ').toUpperCase();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'ACTIVE PRACTICE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: color.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          practiceName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: color.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}