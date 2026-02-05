import 'package:flutter/material.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';

/// Simple top app bar for the QuietLine Home screen.
/// Shows a hamburger menu on the left and the active practice details on the right.
class QuietHomeAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const QuietHomeAppBar({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final accessService = PracticeAccessService.instance;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: color,
            onPressed: onMenuTap ?? () {},
          ),
          ValueListenableBuilder<String>(
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
        ],
      ),
    );
  }
}