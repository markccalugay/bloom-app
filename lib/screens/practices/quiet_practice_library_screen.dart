import 'package:flutter/material.dart';

import 'package:quietline_app/data/practices/practice_catalog.dart';
import 'package:quietline_app/data/practices/practice_model.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';
// TODO(StoreKit): Reconnect practice selection to QuietBreathScreen
// once premium entitlement is driven by StoreKit.
import 'package:quietline_app/screens/quiet_breath/quiet_breath_screen.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';

class QuietPracticeLibraryScreen extends StatefulWidget {
  const QuietPracticeLibraryScreen({super.key});

  @override
  State<QuietPracticeLibraryScreen> createState() =>
      _QuietPracticeLibraryScreenState();
}

class _QuietPracticeLibraryScreenState
    extends State<QuietPracticeLibraryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cold Resolve is now re-enabled in the UI.
    // Access and gating are still handled by PracticeAccessService and StoreKit.
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final practices = PracticeCatalog.all.toList();
    // NOTE: active practice state is resolved via accessService.isActive()
    // activePracticeId is intentionally not read here to avoid unused state.
    final accessService = const PracticeAccessService();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Practices'),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: StoreKitService.instance.isPremium,
        builder: (context, isPremium, _) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: practices.length,
            separatorBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Divider(color: onSurface.withValues(alpha: 0.08)),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final practice = practices[index];
              final bool canAccess = accessService.canAccess(practice);

              return _PracticeTile(
                practice: practice,
                locked: !canAccess,
                isActive: accessService.isActive(practice.id),
                onTap: () async {
                  if (!canAccess) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuietPaywallScreen()),
                    );
                    return;
                  }

                  await showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) => _PracticeDetailSheet(
                      practice: practice,
                      isActive: accessService.isActive(practice.id),
                      onActivate: () async {
                        await accessService.setActivePractice(practice.id);
                        if (!context.mounted) return;

                        Navigator.of(context).pop();

                        final contract = _contractForPractice(practice.id);

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuietBreathScreen(
                              sessionId: practice.id,
                              contract: contract,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
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
  final bool isActive;
  final VoidCallback onTap;

  const _PracticeTile({
    required this.practice,
    required this.locked,
    required this.isActive,
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
          color: onSurface.withValues(alpha: locked ? 0.04 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_outline : Icons.self_improvement_rounded,
                  color: locked
                      ? onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.primary,
                ),
                if (isActive)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Icon(
                      Icons.check_circle,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
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
                      color: onSurface.withValues(alpha: locked ? 0.6 : 0.85),
                    ),
                  ),
                  if (isActive && !locked) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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

class _PracticeDetailSheet extends StatelessWidget {
  final Practice practice;
  final bool isActive;
  final VoidCallback onActivate;

  const _PracticeDetailSheet({
    required this.practice,
    required this.isActive,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            practice.id.replaceAll('_', ' ').toUpperCase(),
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          Text(practice.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Text(
            _practiceDetails(practice.id),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isActive ? null : onActivate,
              child: Text(isActive ? 'Active' : 'Activate'),
            ),
          ),
        ],
      ),
    );
  }

  String _practiceDetails(String id) {
    switch (id) {
      case 'core_quiet':
        return 'Technique: 4–4–4 box breathing.\n'
            'Inhale for 4 seconds, hold for 4, exhale for 4.\n'
            'Benefits: Calms the nervous system and resets attention.';
      case 'steady_discipline':
        return 'Technique: Slow rhythmic breathing with steady pacing.\n'
            'Benefits: Builds consistency, self-control, and emotional regulation.';
      case 'monk_calm':
        return 'Technique: Extended exhales inspired by monastic breathing.\n'
            'Benefits: Encourages deep calm, patience, and mental stillness.';
      case 'navy_calm':
        return 'Technique: 4–7–8 breathing.\n'
            'Inhale for 4, hold for 7, exhale for 8.\n'
            'Benefits: Improves stress tolerance and composure under pressure.';
      case 'athlete_focus':
        return 'Technique: Performance-focused breathing cycles.\n'
            'Benefits: Enhances focus, recovery, and physical readiness.';
      case 'cold_resolve':
        return 'A fast, activating breathing practice inspired by Wim Hof.\n'
            'Designed to build resilience and sharpen mental control under stress.';
      default:
        return '';
    }
  }
}

  BreathingPracticeContract _contractForPractice(String id) {
    switch (id) {
      case 'core_quiet':
        return coreQuietContract;
      case 'steady_discipline':
        return steadyDisciplineContract;
      case 'monk_calm':
        return monkCalmContract;
      case 'navy_calm':
        return navyCalmContract;
      case 'athlete_focus':
        return athleteFocusContract;
      case 'cold_resolve':
        return coldResolveContract;
      default:
        return coreQuietContract;
    }
  }