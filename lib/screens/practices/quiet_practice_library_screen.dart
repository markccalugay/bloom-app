import 'package:flutter/material.dart';
import 'quiet_practice_strings.dart';
import 'package:quietline_app/core/services/haptic_service.dart';

import 'package:quietline_app/data/practices/practice_catalog.dart';
import 'package:quietline_app/data/practices/practice_model.dart';
import 'package:quietline_app/core/practices/practice_access_service.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/screens/results/quiet_why_it_works_screen.dart';
import 'package:quietline_app/data/practices/reset_pack_catalog.dart';
import 'package:quietline_app/data/practices/reset_pack_model.dart';

class QuietPracticeLibraryScreen extends StatefulWidget {
  const QuietPracticeLibraryScreen({super.key});

  @override
  State<QuietPracticeLibraryScreen> createState() =>
      _QuietPracticeLibraryScreenState();
}

class _QuietPracticeLibraryScreenState
    extends State<QuietPracticeLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final practices = PracticeCatalog.all.toList();
    final accessService = PracticeAccessService.instance;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(QuietPracticeStrings.title),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: StoreKitService.instance.isPremium,
        builder: (context, isPremium, _) {
          return ValueListenableBuilder<String>(
            valueListenable: accessService.activePracticeId,
            builder: (context, activeId, _) {
              if (isPremium) {
                return _buildPremiumLayout(
                    context, theme, practices, accessService, activeId);
              } else {
                return _buildFreeLayout(
                    context, theme, practices, accessService, activeId);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildPremiumLayout(
    BuildContext context,
    ThemeData theme,
    List<Practice> practices,
    PracticeAccessService accessService,
    String activeId,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              QuietPracticeStrings.premiumUnlocked,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        ...practices.map((practice) {
          final bool isActive = practice.id == activeId && !accessService.isResetPackActive;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PracticeTile(
              practice: practice,
              locked: false,
              isActive: isActive,
              isPrimaryLocked: false,
              onTap: () => _showPracticeDetail(context, theme, practice, isActive, accessService),
            ),
          );
        }),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                QuietPracticeStrings.resetPacks,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                QuietPracticeStrings.resetPacksSubtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        ...ResetPackCatalog.all.map((pack) {
          final bool isActive = accessService.isPackActive(pack.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ResetPackTile(
              pack: pack,
              isActive: isActive,
              onTap: () => _showResetPackDetail(context, theme, pack, isActive, accessService),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFreeLayout(
    BuildContext context,
    ThemeData theme,
    List<Practice> practices,
    PracticeAccessService accessService,
    String activeId,
  ) {
    final coreQuiet = practices.firstWhere((p) => p.id == 'core_quiet');
    final navyCalm = practices.firstWhere((p) => p.id == 'navy_calm');
    final otherPremium = practices
        .where((p) => p.tier == PracticeTier.premium && p.id != 'navy_calm')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // CORE QUIET
        _PracticeTile(
          practice: coreQuiet,
          locked: false,
          isActive: coreQuiet.id == activeId,
          isPrimaryLocked: false,
          onTap: () => _showPracticeDetail(
              context, theme, coreQuiet, coreQuiet.id == activeId, accessService),
        ),
        const SizedBox(height: 16),
        Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
        const SizedBox(height: 16),

        // NEXT PRACTICE (PRIMARY LOCKED CARD)
        _PracticeTile(
          practice: navyCalm,
          locked: true,
          isActive: false,
          isPrimaryLocked: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QuietPaywallScreen()),
          ),
        ),
        const SizedBox(height: 24),

        // OTHER PRACTICES (SECONDARY, DE-EMPHASIZED)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            QuietPracticeStrings.includedWithPremium,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...otherPremium.map((practice) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PracticeTile(
              practice: practice,
              locked: true,
              isActive: false,
              isDeEmphasized: true,
              isPrimaryLocked: false,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuietPaywallScreen()),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                QuietPracticeStrings.resetPacks,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                QuietPracticeStrings.resetPacksSubtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        ...ResetPackCatalog.all.map((pack) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ResetPackTile(
              pack: pack,
              isActive: false,
              locked: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuietPaywallScreen()),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showPracticeDetail(
    BuildContext context,
    ThemeData theme,
    Practice practice,
    bool isActive,
    PracticeAccessService accessService,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PracticeDetailSheet(
        practice: practice,
        isActive: isActive,
        onActivate: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: const Text('Change Practice?'),
              content: Text(
                  'Set ${practice.id.replaceAll('_', ' ')} as your current active practice?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    QuietPracticeStrings.cancel,
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(100, 44),
                  ),
                  child: const Text(QuietPracticeStrings.confirm),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await accessService.setActivePractice(practice.id);
            if (!context.mounted) return;
            Navigator.of(context).pop(); // Close detail sheet
          }
        },
      ),
    );
  }

  void _showResetPackDetail(
    BuildContext context,
    ThemeData theme,
    ResetPack pack,
    bool isActive,
    PracticeAccessService accessService,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      builder: (_) => _ResetPackDetailSheet(
        pack: pack,
        isActive: isActive,
        onActivate: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: const Text(QuietPracticeStrings.changePracticeTitle),
              content:
                  Text(QuietPracticeStrings.changeResetPackPrompt(pack.name)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(QuietPracticeStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticService.selection();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(100, 44),
                  ),
                  child: const Text(QuietPracticeStrings.confirm),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await accessService.setActiveResetPack(pack.id);
            if (!context.mounted) return;
            Navigator.of(context).pop(); // Close detail sheet
          }
        },
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  final Practice practice;
  final bool locked;
  final bool isActive;
  final bool isPrimaryLocked;
  final bool isDeEmphasized;
  final VoidCallback onTap;

  const _PracticeTile({
    required this.practice,
    required this.locked,
    required this.isActive,
    required this.onTap,
    this.isPrimaryLocked = false,
    this.isDeEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    double opacity = 1.0;
    if (isDeEmphasized) {
      opacity = 0.5;
    } else if (locked && !isPrimaryLocked) {
      opacity = 0.7;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isDeEmphasized ? 12 : 16),
        decoration: BoxDecoration(
          color: onSurface.withValues(
              alpha: isPrimaryLocked ? 0.12 : (locked ? 0.04 : 0.08)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: onSurface.withValues(alpha: isPrimaryLocked ? 0.15 : 0.06)),
        ),
        child: Opacity(
          opacity: opacity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    locked ? Icons.lock_outline : Icons.self_improvement_rounded,
                    size: isDeEmphasized ? 20 : 24,
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
                        fontSize: isDeEmphasized ? 10 : null,
                        color: onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      practice.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isDeEmphasized ? 13 : 14,
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
                          QuietPracticeStrings.active,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (isPrimaryLocked) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          QuietPracticeStrings.includedWithPremium,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (locked && !isPrimaryLocked && !isDeEmphasized) ...[
                      const SizedBox(height: 8),
                      Text(
                        'QuietLine+ Premium',
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                practice.id.replaceAll('_', ' ').toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuietWhyItWorksScreen(
                        practiceId: practice.id,
                        onContinue: () => Navigator.of(context).pop(),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    QuietPracticeStrings.whyThisWorks,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
              onPressed: isActive
                  ? null
                  : () {
                      HapticService.selection();
                      onActivate();
                    },
              child: Text(isActive ? QuietPracticeStrings.active : QuietPracticeStrings.activate),
            ),
          ),
        ],
      ),
    );
  }

  String _practiceDetails(String id) {
    switch (id) {
      case 'core_quiet':
        return '${QuietPracticeStrings.techCoreQuietTitle}\n'
            '${QuietPracticeStrings.techCoreQuietSub}';
      case 'steady_discipline':
        return '${QuietPracticeStrings.techSteadyDisciplineTitle}\n'
            '${QuietPracticeStrings.techSteadyDisciplineSub}';
      case 'monk_calm':
        return '${QuietPracticeStrings.techMonkCalmTitle}\n'
            '${QuietPracticeStrings.techMonkCalmSub}';
      case 'navy_calm':
        return '${QuietPracticeStrings.techNavyCalmTitle}\n'
            '${QuietPracticeStrings.techNavyCalmSub}';
      case 'athlete_focus':
        return '${QuietPracticeStrings.techAthleteFocusTitle}\n'
            '${QuietPracticeStrings.techAthleteFocusSub}';
      case 'cold_resolve':
        return '${QuietPracticeStrings.techColdResolveTitle}\n'
            '${QuietPracticeStrings.techColdResolveSub}';
      default:
        return '';
    }
  }
}

class _ResetPackTile extends StatelessWidget {
  final ResetPack pack;
  final bool isActive;
  final bool locked;
  final VoidCallback onTap;

  const _ResetPackTile({
    required this.pack,
    required this.isActive,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: isActive ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: onSurface.withValues(alpha: isActive ? 0.2 : 0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_outline : Icons.auto_awesome_rounded,
                  size: 24,
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
                  Row(
                    children: [
                      Text(
                        pack.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          color: onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'GUIDED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pack.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: onSurface.withValues(alpha: locked ? 0.6 : 0.85),
                    ),
                  ),
                  if (isActive) ...[
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
                        QuietPracticeStrings.active,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (locked) ...[
                    const SizedBox(height: 12),
                    Text(
                      'QuietLine+ Premium',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
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

class _ResetPackDetailSheet extends StatelessWidget {
  final ResetPack pack;
  final bool isActive;
  final VoidCallback onActivate;

  const _ResetPackDetailSheet({
    required this.pack,
    required this.isActive,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GUIDED RESET',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                pack.contract.name.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pack.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pack.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This pack includes a targeted affirmation pool to help you ${pack.name.split(' ').first.toLowerCase()} effectively.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isActive
                  ? null
                  : () {
                      HapticService.selection();
                      onActivate();
                    },
              child: Text(isActive
                  ? QuietPracticeStrings.active
                  : QuietPracticeStrings.activate),
            ),
          ),
        ],
      ),
    );
  }
}