import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:quietline_app/data/affirmations/affirmations_model.dart';
import 'package:quietline_app/data/affirmations/affirmations_service.dart';
import 'package:quietline_app/data/affirmations/affirmations_unlock_service.dart';
import 'package:quietline_app/screens/home/widgets/quiet_home_affirmations_card.dart';
import 'package:quietline_app/core/entitlements/premium_entitlement.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';

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
    
    // DEBUG: Trace affirmation state synchronization
    debugPrint('QUIET: Carousel sync - streak: ${widget.streak}, unlocked: ${unlocked.length} ids');
    debugPrint('QUIET: Unlocked IDs: $unlocked');

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
    setState(() {
      _currentIndex = index;
    });
    _autoRotateTimer?.cancel();
  }

  List<_AffirmationCardData> _buildCards() {
    final service = const AffirmationsService();
    final isPremium =
        PremiumEntitlement.instance.isPremium;
    final rng = Random();

    // 1. First Position: Most recently unlocked Core affirmation (synced with streak)
    final streakAffirmation = service.getHomeCoreForStreakDay(widget.streak);
    Affirmation? primary;

    if (streakAffirmation != null && _unlockedIds.contains(streakAffirmation.id)) {
      primary = streakAffirmation;
    } else {
      // FALLBACK: The streak might be ahead of the actual unlocks, or the user is on Day 0.
      // We find the highest unlocked Core affirmation.
      final allCore = service.getAffirmationsForPack(AffirmationPackIds.core);
      for (final a in allCore.reversed) {
        if (_unlockedIds.contains(a.id)) {
          primary = a;
          break;
        }
      }
    }

    final List<_AffirmationCardData> cards = [];

    if (primary != null) {
      cards.add(
        _AffirmationCardData(
          affirmation: primary,
        ),
      );
    }

    // 2. Second Position: Premium random (if premium), otherwise random Core (if any others exist)
    Affirmation? secondary;
    if (isPremium) {
      // Pick random from Focus, Sleep, or Strength
      final packs = [
        AffirmationPackIds.focus,
        AffirmationPackIds.sleep,
        AffirmationPackIds.strength
      ];
      final randomPack = packs[rng.nextInt(packs.length)];
      secondary = service.getRandomFromPack(randomPack);
    } else {
      // Random unlocked Core (excluding primary)
      final otherUnlockedCore = service
          .getAffirmationsForPack(AffirmationPackIds.core)
          .where((a) =>
              _unlockedIds.contains(a.id) &&
              a.id != primary?.id)
          .toList();
      if (otherUnlockedCore.isNotEmpty) {
        secondary =
            otherUnlockedCore[rng.nextInt(otherUnlockedCore.length)];
      }
    }

    if (secondary != null) {
      cards.add(
        _AffirmationCardData(
          affirmation: secondary,
        ),
      );
    }

    // 3. Third Position: Random from WHICHEVER library (Strictly filtered)
    final existingIds = cards.map((c) => c.affirmation.id).toSet();
    
    final allPacks = [
      AffirmationPackIds.core,
      AffirmationPackIds.focus,
      AffirmationPackIds.sleep,
      AffirmationPackIds.strength
    ];
    
    final List<Affirmation> candidates = [];
    for (final packId in allPacks) {
      final packAffirmations = service.getAffirmationsForPack(packId);
      for (final a in packAffirmations) {
        // Source of Truth: Core must be in _unlockedIds. Premium requires entitlement.
        bool isEligible = false;
        if (packId == AffirmationPackIds.core) {
          isEligible = _unlockedIds.contains(a.id);
        } else {
          isEligible = isPremium;
        }

        if (isEligible && !existingIds.contains(a.id)) {
          candidates.add(a);
        }
      }
    }

    if (candidates.isNotEmpty) {
      final tertiary = candidates[rng.nextInt(candidates.length)];
      cards.add(
        _AffirmationCardData(
          affirmation: tertiary,
        ),
      );
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _cards.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
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
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    if (_cards.length <= 1) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cards.length, (index) {
        final isSelected = _currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: isSelected ? 0.8 : 0.2),
          ),
        );
      }),
    );
  }
}

/* ───────────────────────── Helpers ───────────────────────── */

class _AffirmationCardData {
  final Affirmation affirmation;

  const _AffirmationCardData({
    required this.affirmation,
  });
}
