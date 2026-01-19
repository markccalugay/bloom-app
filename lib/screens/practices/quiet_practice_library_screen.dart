import 'package:flutter/material.dart';

import 'package:quietline_app/data/practices/practice_catalog.dart';
import 'package:quietline_app/data/practices/practice_model.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/theme/ql_theme.dart';

class QuietPracticeLibraryScreen extends StatelessWidget {
  const QuietPracticeLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final practices = PracticeCatalog.all;
    final accessService = const PracticeAccessService();

    return Scaffold(
      backgroundColor: QLColors.background,
      appBar: AppBar(
        backgroundColor: QLColors.background,
        elevation: 0,
        title: const Text('Practices'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: practices.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final practice = practices[index];
          final bool canAccess = accessService.canAccess(practice);

          return _PracticeTile(
            practice: practice,
            locked: !canAccess,
            onTap: () {
              if (canAccess) {
                final sessionId =
                    'session-${DateTime.now().millisecondsSinceEpoch}';

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuietBreathScreen(
                      sessionId: sessionId,
                      streak: 0,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuietPaywallScreen(),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  final Practice practice;
  final bool locked;
  final VoidCallback onTap;

  const _PracticeTile({
    required this.practice,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: locked ? 0.04 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              locked ? Icons.lock_outline : Icons.self_improvement_rounded,
              color: locked
                  ? onSurface.withValues(alpha: 0.4)
                  : QLColors.primaryTeal,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    practice.id.replaceAll('_', ' ').toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 0.8,
                      color: onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    practice.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurface.withValues(
                        alpha: locked ? 0.6 : 0.85,
                      ),
                    ),
                  ),
                  if (locked) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Premium practice',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}