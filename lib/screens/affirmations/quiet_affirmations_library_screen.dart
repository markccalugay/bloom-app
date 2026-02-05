import 'package:flutter/material.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/screens/home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/screens/affirmations/widgets/affirmation_grid_tile.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';

class QuietAffirmationsLibraryScreen extends StatefulWidget {
  const QuietAffirmationsLibraryScreen({super.key});

  @override
  State<QuietAffirmationsLibraryScreen> createState() =>
      _QuietAffirmationsLibraryScreenState();
}

class _QuietAffirmationsLibraryScreenState
    extends State<QuietAffirmationsLibraryScreen> {
  bool _loading = true;
  int _streak = 0;

  late final List<dynamic> allAffirmations = affirmationsByPack.entries
      .expand((entry) => entry.value.map((a) => {'packId': entry.key, 'a': a}))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    try {
      final value = await QuietStreakService.getCurrentStreak();
      if (!mounted) return;
      setState(() {
        _streak = value;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _streak = 0;
        _loading = false;
      });
    }
  }

  int get _unlockedDay => _streak <= 0 ? 1 : _streak;

  String _formatFullMonthDate(DateTime date) {
    // MVP: Universal readable format (no locale headaches)
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  int _extractNumberFromId(String id) {
    // Ex: core_042 -> 42
    final parts = id.split('_');
    if (parts.length < 2) return 999999;
    return int.tryParse(parts.last) ?? 999999;
  }

  bool _isUnlocked(String id) {
    final n = _extractNumberFromId(id);
    return n <= _unlockedDay;
  }

  String _packHeader(String packId) {
    switch (packId) {
      case AffirmationPackIds.focus:
        return 'FOCUS';
      case AffirmationPackIds.sleep:
        return 'SLEEP';
      case AffirmationPackIds.strength:
        return 'STRENGTH';
      default:
        return packId.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    final today = DateTime.now();
    final unlockedLabel =
        'Unlocked on Day $_unlockedDay ${_formatFullMonthDate(today)}';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: baseTextColor),
        title: Text(
          'Affirmations',
          style: theme.textTheme.titleMedium?.copyWith(
            color: baseTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<bool>(
              valueListenable: StoreKitService.instance.isPremium,
              builder: (context, isPremium, _) {
                return CustomScrollView(
                  slivers: [
                // --- CORE HEADER ---
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Affirmations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: baseTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unlocked one day at a time through quiet practice.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: baseTextColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- CORE GRID ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final coreItems = allAffirmations
                            .where((x) => (x as Map)['packId'] == AffirmationPackIds.core)
                            .toList(growable: false);

                        final item = coreItems[index] as Map;
                        final a = item['a'];

                        final bool isPremiumLocked = false;
                        final bool unlocked = _isUnlocked(a.id);

                        return AffirmationGridTile(
                          affirmation: a,
                          isUnlocked: unlocked,
                          isPremiumLocked: isPremiumLocked,
                          lockedLabel: 'Locked',
                          unlockedLabel: unlocked ? unlockedLabel : null,
                          onTap: unlocked
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => QuietAffirmationFullscreenScreen(
                                        text: a.text,
                                        unlockedLabel: unlockedLabel,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          onLockedTap: () {
                            const message =
                                'Complete a quiet session tomorrow to unlock this.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(message),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                      childCount: allAffirmations
                          .where((x) => (x as Map)['packId'] == AffirmationPackIds.core)
                          .length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                  ),
                ),

                // --- DIVIDER ---
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Divider(color: baseTextColor.withValues(alpha: 0.08)),
                  ),
                ),

                // --- PREMIUM HEADER ---
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Premium Packs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: baseTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // --- PREMIUM SECTIONS ---
                ...[AffirmationPackIds.focus, AffirmationPackIds.sleep, AffirmationPackIds.strength]
                    .where((id) => affirmationsByPack.containsKey(id))
                    .map((id) => MapEntry(id, affirmationsByPack[id]!))
                    .expand((entry) {
                  final packId = entry.key;
                  final items = entry.value;

                  return <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          _packHeader(packId),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: baseTextColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final a = items[index];
                            final bool isPremiumLocked = !isPremium;
                            final bool unlocked = isPremium;

                            return AffirmationGridTile(
                              affirmation: a,
                              isUnlocked: unlocked,
                              isPremiumLocked: isPremiumLocked,
                              lockedLabel: 'Premium',
                              unlockedLabel: null,
                              onTap: unlocked
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => QuietAffirmationFullscreenScreen(
                                            text: a.text,
                                            unlockedLabel: 'Premium',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              onLockedTap: () {
                                const message = 'Unlock with QuietLine+';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(message),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: items.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                      ),
                    ),
                  ];
                }),
              ],
            );
        },
      ),
    );
  }
}