import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';

/// Simple top app bar for the QuietLine Home screen.
/// Shows a hamburger menu on the left and the active practice details on the right.
class QuietHomeAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onPracticeTap;
  final GlobalKey? menuKey;

  const QuietHomeAppBar({
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            key: menuKey,
            icon: const Icon(Icons.menu),
            color: color,
            onPressed: onMenuTap ?? () {},
          ),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
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
                    crossAxisAlignment: CrossAxisAlignment.end,
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
    );
  }
}