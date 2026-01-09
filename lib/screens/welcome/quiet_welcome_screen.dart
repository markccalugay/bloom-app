import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:quietline_app/core/app_assets.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';

class QuietWelcomeScreen extends StatefulWidget {
  /// Triggered when user taps "Start Quiet Time"
  final VoidCallback? onStart;

  /// Triggered when user taps "Learn how it works"
  final VoidCallback? onLearnMore;

  const QuietWelcomeScreen({
    super.key,
    this.onStart,
    this.onLearnMore,
  });

  @override
  State<QuietWelcomeScreen> createState() => _QuietWelcomeScreenState();
}

class _QuietWelcomeScreenState extends State<QuietWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _reassuranceFade;
  late final Animation<double> _primaryFade;
  late final Animation<double> _secondaryFade;
  late final Animation<double> _disclaimerFade;

  late final Animation<Offset> _logoSlide;
  late final Animation<Offset> _reassuranceSlide;
  late final Animation<Offset> _primarySlide;
  late final Animation<Offset> _secondarySlide;
  late final Animation<Offset> _disclaimerSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    Animation<double> fade(double begin, double end) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );
    }

    Animation<Offset> slide(double begin, double end) {
      return Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );
    }

    // Sequence:
    // 1) Logo + header + description
    // 2) Reassurance
    // 3) Primary button
    // 4) Secondary CTA
    // 5) Disclaimer
    _logoFade = fade(0.00, 0.35);
    _logoSlide = slide(0.00, 0.35);

    _reassuranceFade = fade(0.25, 0.55);
    _reassuranceSlide = slide(0.25, 0.55);

    _primaryFade = fade(0.45, 0.75);
    _primarySlide = slide(0.45, 0.75);

    _secondaryFade = fade(0.62, 0.88);
    _secondarySlide = slide(0.62, 0.88);

    _disclaimerFade = fade(0.70, 1.00);
    _disclaimerSlide = slide(0.70, 1.00);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    // Routed by parent (QuietEntryScreen). If null, do nothing.
    widget.onStart?.call();
  }

  void _learnMore() {
    widget.onLearnMore?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 44),

              // BLOCK 1: Logo + header + description
              FadeTransition(
                opacity: _logoFade,
                child: SlideTransition(
                  position: _logoSlide,
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        AppAssets.quietlineLogo,
                        width: 64,
                        height: 64,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'A Moment of Quiet',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We\'ll guide you through a 90-second breathing reset.\nThere\'s nothing to learn and nothing to get right.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // BLOCK 2: Reassurance
              FadeTransition(
                opacity: _reassuranceFade,
                child: SlideTransition(
                  position: _reassuranceSlide,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      'You can stop anytime.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // BLOCK 3: Primary CTA
              FadeTransition(
                opacity: _primaryFade,
                child: SlideTransition(
                  position: _primarySlide,
                  child: QLPrimaryButton(
                    label: 'Start Quiet Time',
                    onPressed: _start,
                    margin: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      bottom: 10,
                    ),
                  ),
                ),
              ),

              // BLOCK 4: Secondary CTA
              FadeTransition(
                opacity: _secondaryFade,
                child: SlideTransition(
                  position: _secondarySlide,
                  child: TextButton(
                    onPressed: _learnMore,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Learn how it works'),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // BLOCK 5: Disclaimer
              FadeTransition(
                opacity: _disclaimerFade,
                child: SlideTransition(
                  position: _disclaimerSlide,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'QuietLine is not a medical device.\nIf you’re in immediate danger, call your local emergency number.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}