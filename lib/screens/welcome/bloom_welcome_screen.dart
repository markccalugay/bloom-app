import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bloom_app/screens/bloom_breath/bloom_breath_screen.dart';

import 'package:bloom_app/core/bloom_assets.dart';
import 'package:bloom_app/widgets/bloom_primary_button.dart';
import 'package:bloom_app/theme/bloom_theme.dart';
import 'package:bloom_app/services/web_launch_service.dart';

class BloomWelcomeScreen extends StatefulWidget {
  /// Current streak to pass into the first session (for consistent UI).
  final int streak;

  /// Triggered when user taps "Start Bloom Time".
  /// We pass the *current* BuildContext so the router can navigate safely.
  final void Function(BuildContext context)? onStart;

  /// Triggered when user taps "Learn how it works"
  final VoidCallback? onLearnMore;

  const BloomWelcomeScreen({
    super.key,
    this.streak = 0,
    this.onStart,
    this.onLearnMore,
  });

  @override
  State<BloomWelcomeScreen> createState() => _BloomWelcomeScreenState();
}

class _BloomWelcomeScreenState extends State<BloomWelcomeScreen>
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
      duration: const Duration(milliseconds: 1400),
    );

    Animation<double> fade(double begin, double end) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );
    }

    Animation<Offset> slide(double begin, double end) {
      return Tween<Offset>(
        begin: const Offset(0, 0.06),
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
    _logoFade = fade(0.00, 0.28);
    _logoSlide = slide(0.00, 0.28);

    _reassuranceFade = fade(0.20, 0.44);
    _reassuranceSlide = slide(0.20, 0.44);

    _primaryFade = fade(0.38, 0.62);
    _primarySlide = slide(0.38, 0.62);

    _secondaryFade = fade(0.56, 0.78);
    _secondarySlide = slide(0.56, 0.78);

    _disclaimerFade = fade(0.72, 1.00);
    _disclaimerSlide = slide(0.72, 1.00);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    // Prefer parent routing if provided (e.g., Entry screen).
    // We pass the *current* BuildContext so navigation happens with a live context.
    if (widget.onStart != null) {
      widget.onStart!.call(context);
      return;
    }

    // Fallback: start Bloom Time directly from this screen.
    if (!mounted) return;

    final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            BloomBreathScreen(sessionId: sessionId, streak: widget.streak),
      ),
    );
  }

  void _learnMore() {
    if (widget.onLearnMore != null) {
      widget.onLearnMore!.call();
    } else {
      WebLaunchService().openAbout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onSurface = cs.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        BloomAssets.bloomLogo,
                        width: 64,
                        height: 64,
                        colorFilter: const ColorFilter.mode(
                          BloomColors.primaryTeal,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'A Moment of Bloom',
                        textAlign: TextAlign.left,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We\'ll guide you through a 90-second breathing reset.\nThere\'s nothing to learn and nothing to get right.',
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: onSurface.withValues(alpha: 0.82),
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'You can stop anytime.',
                      textAlign: TextAlign.left,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onSurface.withValues(alpha: 0.75),
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
                  child: BloomPrimaryButton(
                    label: 'Start Bloom Time',
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
                  child: InkWell(
                    onTap: _learnMore,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Learn how it works',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: onSurface.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: onSurface.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bloom is a wellness and emotional-support app.\nBy continuing, you agree to our Terms and Privacy Policy',
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onSurface.withValues(alpha: 0.55),
                          height: 1.3,
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
    );
  }
}
