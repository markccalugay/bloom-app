import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:quietline_app/data/affirmations/affirmations_model.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:quietline_app/screens/home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/theme/ql_theme.dart';

class QuietHomeAffirmationsCarousel extends StatefulWidget {
  final int streak;

  const QuietHomeAffirmationsCarousel({
    super.key,
    required this.streak,
  });

  @override
  State<QuietHomeAffirmationsCarousel> createState() =>
      _QuietHomeAffirmationsCarouselState();
}

class _QuietHomeAffirmationsCarouselState
    extends State<QuietHomeAffirmationsCarousel> {
  static const _autoRotateDelay = Duration(seconds: 2);
  static const _autoRotateInterval = Duration(seconds: 7);

  late final PageController _pageController;
  Timer? _autoRotateTimer;

  late final List<_AffirmationCardData> _cards;
  Set<String> _unlockedIds = {};
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _loadData();
  }

  Future<void> _loadData() async {
    final unlocked = await AffirmationsUnlockService.instance.getUnlockedIds();
    if (!mounted) return;

    setState(() {
      _unlockedIds = unlocked;
      _cards = _buildCards();
      _isLoading = false;
    });

    _startAutoRotate();
  }

  @override
  void dispose() {
    _autoRotateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoRotate() {
    _autoRotateTimer?.cancel();

    _autoRotateTimer = Timer(_autoRotateDelay, () {
      _autoRotateTimer = Timer.periodic(_autoRotateInterval, (_) {
        if (!_pageController.hasClients || _cards.length <= 1) return;

        final next = (_currentIndex + 1) % _cards.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  void _onUserInteraction(int index) {
    _currentIndex = index;
    _autoRotateTimer?.cancel();
  }

  List<_AffirmationCardData> _buildCards() {
    final service = const AffirmationsService();
    final rng = Random();

    final primary =
        service.getHomeCoreForStreakDay(widget.streak);

    final allUnlocked = service.getAffirmationsForPack('core')
        .where((a) => _unlockedIds.contains(a.id) && a.id != primary?.id)
        .toList();

    allUnlocked.shuffle(rng);

    final secondary = allUnlocked.take(2).toList();

    final tier = _backgroundTierForStreak(widget.streak);

    final backgrounds = _backgroundsForTier(tier);

    final cards = <_AffirmationCardData>[];

    if (primary != null) {
      cards.add(
        _AffirmationCardData(
          affirmation: primary,
          background: backgrounds.primary,
        ),
      );
    }

    for (int i = 0; i < secondary.length; i++) {
      cards.add(
        _AffirmationCardData(
          affirmation: secondary[i],
          background: backgrounds.secondary[i % backgrounds.secondary.length],
        ),
      );
    }

    return backgrounds.primary == QLGradients.tealFlame ? cards : cards; // No-op to avoid unused var if needed
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _cards.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 192, // Increased height by 20% (160 * 1.2)
      child: PageView.builder(
        controller: _pageController,
        itemCount: _cards.length,
        onPageChanged: _onUserInteraction,
        physics: const PageScrollPhysics(),
        itemBuilder: (context, index) {
          final card = _cards[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: QuietHomeAffirmationsCard(
              title: card.affirmation.text,
              gradient: card.background,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuietAffirmationFullscreenScreen(
                      text: card.affirmation.text,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/* ───────────────────────── Helpers ───────────────────────── */

class _AffirmationCardData {
  final Affirmation affirmation;
  final Gradient background;

  const _AffirmationCardData({
    required this.affirmation,
    required this.background,
  });
}

enum _BackgroundTier {
  soft,
  grounded,
  steady,
}

_BackgroundTier _backgroundTierForStreak(int streak) {
  if (streak >= 7) return _BackgroundTier.steady;
  if (streak >= 3) return _BackgroundTier.grounded;
  return _BackgroundTier.soft;
}

class _TierBackgrounds {
  final Gradient primary;
  final List<Gradient> secondary;

  const _TierBackgrounds({
    required this.primary,
    required this.secondary,
  });
}

_TierBackgrounds _backgroundsForTier(_BackgroundTier tier) {
  // Mapping to the new Flame Gradient System
  switch (tier) {
    case _BackgroundTier.steady:
      return const _TierBackgrounds(
        primary: QLGradients.amberFlame,
        secondary: [QLGradients.amberFlame, QLGradients.tealFlame],
      );
    case _BackgroundTier.grounded:
      return const _TierBackgrounds(
        primary: QLGradients.steelFlame,
        secondary: [QLGradients.steelFlame, QLGradients.tealFlame],
      );
    case _BackgroundTier.soft:
      return const _TierBackgrounds(
        primary: QLGradients.tealFlame,
        secondary: [QLGradients.tealFlame, QLGradients.midnightFlame],
      );
  }
}
