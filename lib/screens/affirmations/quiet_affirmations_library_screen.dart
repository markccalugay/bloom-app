import 'package:flutter/material.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/screens/home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/screens/affirmations/widgets/affirmation_grid_tile.dart';
import 'package:quietline_app/theme/ql_theme.dart';

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

  late final List allAffirmations = affirmationsByPack.values
      .expand((list) => list)
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    final today = DateTime.now();
    final unlockedLabel =
        'Unlocked on Day $_unlockedDay ${_formatFullMonthDate(today)}';

    return Scaffold(
      backgroundColor: QLColors.background,
      appBar: AppBar(
        backgroundColor: QLColors.background,
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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GridView.builder(
                itemCount: allAffirmations.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final a = allAffirmations[index];
                  final unlocked = _isUnlocked(a.id);

                  return AffirmationGridTile(
                    affirmation: a,
                    isUnlocked: unlocked,
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
                  );
                },
              ),
            ),
    );
  }
}