import 'package:flutter/material.dart';
import 'package:bloom_app/data/affirmations/affirmations_packs.dart';
import 'package:bloom_app/data/affirmations/affirmations_model.dart';
import 'package:bloom_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:bloom_app/data/streak/bloom_streak_service.dart';
import 'package:bloom_app/screens/home/widgets/bloom_home_affirmations_card.dart';
import 'package:bloom_app/screens/affirmations/widgets/affirmation_grid_tile.dart';
import 'package:bloom_app/core/storekit/storekit_service.dart';

class BloomAffirmationsLibraryScreen extends StatefulWidget {
  const BloomAffirmationsLibraryScreen({super.key});

  @override
  State<BloomAffirmationsLibraryScreen> createState() =>
      _BloomAffirmationsLibraryScreenState();
}

class _BloomAffirmationsLibraryScreenState
    extends State<BloomAffirmationsLibraryScreen> {
  bool _loading = true;
  int _streak = 0;
  Set<String> _unlockedIds = {};

  late final List<dynamic> allAffirmations = affirmationsByPack.entries
      .expand((entry) => entry.value.map((a) => {'packId': entry.key, 'a': a}))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final streak = await BloomStreakService.getCurrentStreak();
      final unlocked = await AffirmationsUnlockService.instance.getUnlockedIds();
      
      if (!mounted) return;
      setState(() {
        _streak = streak;
        _unlockedIds = unlocked;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _streak = 0;
        _unlockedIds = {};
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

  bool _isUnlocked(String id, String packId) {
    if (packId == AffirmationPackIds.core) {
      return _unlockedIds.contains(id);
    }
    // Premium packs are always "unlocked" in the grid, but potentially "Premium-locked"
    return true; 
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
    final Color baseTextColor = theme.colorScheme.onSurface;

    final today = DateTime.now();
    final unlockedLabel =
        'Unlocked on Day $_unlockedDay ${_formatFullMonthDate(today)}';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Affirmations',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: baseTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${allAffirmations.where((x) => (x as Map)['packId'] == AffirmationPackIds.core && _unlockedIds.contains((x['a'] as Affirmation).id)).length}/${coreAffirmations.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                        final a = item['a'] as Affirmation;

                        final bool isPremiumLocked = false;
                        final bool unlocked = _isUnlocked(a.id, AffirmationPackIds.core);

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
                                      builder: (_) => BloomAffirmationFullscreenScreen(
                                        text: a.text,
                                        unlockedLabel: unlockedLabel,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          onLockedTap: () {
                            const message =
                                'Complete a Bloom session tomorrow to unlock this.';
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
                            final bool isPremiumLocked = a.isPremium && !isPremium;
                            final bool unlocked = !a.isPremium || isPremium;

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
                                          builder: (_) => BloomAffirmationFullscreenScreen(
                                            text: a.text,
                                            unlockedLabel: 'Premium',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              onLockedTap: () {
                                const message = 'Unlock with Bloom+';
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