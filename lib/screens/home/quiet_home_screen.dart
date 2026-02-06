import 'package:flutter/material.dart';

import '../home/widgets/quiet_home_app_bar.dart';
import '../home/widgets/quiet_home_streak_row.dart';
import '../results/quiet_results_ok_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';
import 'package:quietline_app/widgets/quiet_home_ingot_background.dart';
import 'package:quietline_app/widgets/affirmations/quiet_home_affirmations_carousel.dart';
import 'package:quietline_app/data/forge/forge_service.dart';

const double kHomeHorizontalPadding = 16.0;
const double kHomeTopSpacing = 20.0;          // space between app bar and streak
const double kHomeStreakToCardSpacing = 56.0; // space between streak and affirmation card
const double kHomeBottomSpacing = 16.0; 

String _formatToday() {
  final now = DateTime.now();
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

  final month = months[now.month - 1];
  final day = now.day; // no leading zero for this style
  final year = now.year;

  return '$month $day, $year';
}

Widget _buildHomeBody({
  required BuildContext context,
  required int streak,
  required String unlockedLabel,
  required String? affirmationText,
  required VoidCallback? onMenu,
  required VoidCallback? onPracticeTap,
}) {
  return Stack(
    children: [
      SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuietHomeAppBar(
                  onMenuTap: () {
                    onMenu?.call();
                  },
                  onPracticeTap: onPracticeTap,
                ),
  
                const SizedBox(height: kHomeTopSpacing),
  
                QuietHomeStreakRow(streak: streak),
  
                const SizedBox(height: 40.0),
  
                const QuietHomeIngotBackground(),
  
                const SizedBox(height: 32.0),
  
                QuietHomeAffirmationsCarousel(
                  streak: streak,
                ),
  
                const SizedBox(height: kHomeBottomSpacing),
              ],
            ),
          ),
        ),
      ),
      if (kDebugMode)
        Positioned(
          bottom: 120,
          left: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuietResultsOkScreen(
                        streak: 5, // Mocking a 5-day streak
                        previousStreak: 4,
                        isNew: true,
                      ),
                    ),
                  );
                },
                child: const Text('DEBUG: Complete Session (Test Flow)',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => ForgeService.instance.advanceProgress(),
                child: const Text('DEBUG: Advance Forge Stage',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 10)),
              ),
              TextButton(
                onPressed: () => ForgeService.instance.debugReset(),
                child: const Text('DEBUG: Reset All Progress',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
              ),
              TextButton(
                onPressed: () => ForgeService.instance.setCurrentSet(ArmorSet.samurai),
                child: const Text('DEBUG: Set Samurai Armor',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 10)),
              ),
              TextButton(
                onPressed: () async {
                  await ForgeService.instance.debugReset();
                  await ForgeService.instance.debugSetStage(IronStage.polished);
                  await ForgeService.instance.advanceProgress();
                },
                child: const Text('DEBUG: Force Unlock Helmet',
                    style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
    ],
  );
}

/// QuietLine Home screen body.
///
/// NOTE:
/// - This widget does NOT include the bottom navigation bar.
///   That lives in `QuietShellScreen` with `QLBottomNav`.
/// - For now it only needs the current streak; affirmations
///   are stubbed with a placeholder string.
class QuietHomeScreen extends StatefulWidget {
  final int streak;
  final VoidCallback? onMenu;
  final VoidCallback? onPracticeTap;

  const QuietHomeScreen({
    super.key,
    required this.streak,
    this.onMenu,
    this.onPracticeTap,
  });

  @override
  State<QuietHomeScreen> createState() => _QuietHomeScreenState();
}

class _QuietHomeScreenState extends State<QuietHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final service = const AffirmationsService();

    // Home should not "pretend" an affirmation is unlocked.
    // Day 0 (FTUE) should return null; Day 1 -> core_001, etc.
    final todayAffirmation = service.getHomeCoreForStreakDay(widget.streak);

    final int day = widget.streak < 0 ? 0 : widget.streak;
    final String unlockedLabel = 'Unlocked on Day $day ${_formatToday()}';

    return _buildHomeBody(
      context: context,
      streak: widget.streak,
      unlockedLabel: unlockedLabel,
      affirmationText: todayAffirmation?.text,
      onMenu: widget.onMenu,
      onPracticeTap: widget.onPracticeTap,
    );
  }
}
