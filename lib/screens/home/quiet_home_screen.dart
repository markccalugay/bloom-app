import 'package:flutter/material.dart';

import '../home/widgets/quiet_home_app_bar.dart';
import '../home/widgets/quiet_home_streak_row.dart';
import '../home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';
import 'package:quietline_app/widgets/quiet_home_ingot_background.dart';
import 'package:quietline_app/services/first_launch_service.dart';

const double kHomeHorizontalPadding = 16.0;
const double kHomeTopSpacing = 20.0;          // space between app bar and streak
const double kHomeStreakToCardSpacing = 56.0; // space between streak and affirmation card
const double kHomeBottomSpacing = 16.0; 

// Quick alignment tweak for the one-time home hint spotlight ring.
// Positive values push the ring DOWN (toward the bottom nav button).
const double kHomeHintRingTranslateY = 44.0;

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

  const QuietHomeScreen({
    super.key,
    required this.streak,
    this.onMenu,
  });

  @override
  State<QuietHomeScreen> createState() => _QuietHomeScreenState();
}

class _QuietHomeScreenState extends State<QuietHomeScreen> {
  bool _showHomeHint = false;
  bool _hintLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadHomeHintState();
  }

  @override
  void didUpdateWidget(covariant QuietHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the streak value arrives/updates after we first mounted, re-check hint state.
    if (oldWidget.streak != widget.streak) {
      _loadHomeHintState();
    }
  }

  Future<void> _loadHomeHintState() async {
    // Show this hint only once, and only after the first session has been completed.
    // We use `streak >= 1` as the source of truth here because the Home screen is
    // already receiving the latest streak value.
    final hasSeenHint = await FirstLaunchService.instance.hasSeenHomeHint();

    if (!mounted) return;

    setState(() {
      _hintLoaded = true;
      _showHomeHint = widget.streak >= 1 && !hasSeenHint;
    });
  }

  Future<void> _dismissHomeHint() async {
    await FirstLaunchService.instance.markHomeHintSeen();
    if (!mounted) return;
    setState(() => _showHomeHint = false);
  }

  @override
  Widget build(BuildContext context) {
    final service = const AffirmationsService();

    // Home should not "pretend" an affirmation is unlocked.
    // Day 0 (FTUE) should return null; Day 1 -> core_001, etc.
    final todayAffirmation = service.getHomeCoreForStreakDay(widget.streak);

    final int day = widget.streak < 0 ? 0 : widget.streak;
    final String unlockedLabel = 'Unlocked on Day $day ${_formatToday()}';

    final homeBody = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top app bar (hamburger)
            QuietHomeAppBar(
              onMenuTap: () {
                // Delegate to shell / parent if provided.
                widget.onMenu?.call();
              },
            ),

            const SizedBox(height: kHomeTopSpacing),

            // Streak row
            QuietHomeStreakRow(streak: widget.streak),

            const SizedBox(height: 40.0),

            // Ingot visual between streak and affirmation card
            const QuietHomeIngotBackground(),

            const SizedBox(height: 32.0),

            if (todayAffirmation != null)
              QuietHomeAffirmationsCard(
                title: todayAffirmation.text,
                unlockedLabel: unlockedLabel,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuietAffirmationFullscreenScreen(
                        text: todayAffirmation.text,
                        unlockedLabel: unlockedLabel,
                      ),
                    ),
                  );
                },
              ),

            // Spacer pushes content up, leaving room for bottom nav
            const Spacer(),

            // Optional microcopy or footer can go here later.
            // For now, keep it clean.
            const SizedBox(height: kHomeBottomSpacing),
          ],
        ),
      ),
    );

    // While loading hint state, just render the home normally.
    if (!_hintLoaded || !_showHomeHint) {
      return homeBody;
    }

    // One-time hint overlay (tap anywhere to dismiss).
    return Stack(
      children: [
        homeBody,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismissHomeHint,
            child: Container(
              color: Colors.black.withAlpha(166), // 0.65 * 255 ≈ 166
              child: Stack(
                children: [
                  // Keep the card inside SafeArea so it never clashes with notches.
                  SafeArea(
                    child: Stack(
                      children: [
                        // Hint card
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 90,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F141A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A3340),
                                width: 1,
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Well done.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'You just did the hardest part — starting.\n\nUse Quiet Time anytime you need a reset.\nTap the button at the bottom to begin.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: Color(0xFFB9C3CF),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tap anywhere to continue',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7F8A99),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spotlight ring: NOT in SafeArea so it can sit on top of the bottom nav button.
                  // We use a translate instead of only tweaking `bottom` because the bottom nav lives
                  // outside this screen; translate lets us visually align without fighting layout.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, kHomeHintRingTranslateY),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2FE6D2),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
