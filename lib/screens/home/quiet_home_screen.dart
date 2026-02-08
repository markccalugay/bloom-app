import 'package:flutter/material.dart';

import '../home/widgets/quiet_home_app_bar.dart';
import '../home/widgets/quiet_home_streak_row.dart';
import '../results/quiet_results_ok_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:quietline_app/widgets/quiet_home_ingot_background.dart';
import 'package:quietline_app/widgets/affirmations/quiet_home_affirmations_carousel.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';

const double kHomeHorizontalPadding = 16.0;
const double kHomeTopSpacing = 12.0;          // Tightened from 20.0
const double kHomeBottomSpacing = 8.0;         // Tightened from 16.0


Widget _buildHomeBody({
  required BuildContext context,
  required int streak,
  required VoidCallback? onMenu,
  required VoidCallback? onPracticeTap,
  GlobalKey? menuButtonKey,
}) {
  return Stack(
    children: [
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuietHomeAppBar(
                menuKey: menuButtonKey,
                onMenuTap: () {
                  onMenu?.call();
                },
                onPracticeTap: onPracticeTap,
              ),

              const SizedBox(height: kHomeTopSpacing),

              QuietHomeStreakRow(streak: streak),

              // Dynamic spacer that shrinks/grows to fit the screen
              const Expanded(
                child: Center(
                  child: QuietHomeIngotBackground(),
                ),
              ),

              const SizedBox(height: 8.0),

              QuietHomeAffirmationsCarousel(
                streak: streak,
              ),

              const SizedBox(height: kHomeBottomSpacing),
            ],
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
                onPressed: () async {
                  await ForgeService.instance.debugReset();
                  await AffirmationsUnlockService.instance.debugReset();
                },
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
                  await AffirmationsUnlockService.instance.debugReset();
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
  final GlobalKey? menuButtonKey;

  const QuietHomeScreen({
    super.key,
    required this.streak,
    this.onMenu,
    this.onPracticeTap,
    this.menuButtonKey,
  });

  @override
  State<QuietHomeScreen> createState() => _QuietHomeScreenState();
}

class _QuietHomeScreenState extends State<QuietHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return _buildHomeBody(
      context: context,
      streak: widget.streak,
      onMenu: widget.onMenu,
      onPracticeTap: widget.onPracticeTap,
      menuButtonKey: widget.menuButtonKey,
    );
  }
}
