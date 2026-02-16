import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/widgets/affirmations/quiet_home_affirmations_carousel.dart';
import 'package:quietline_app/services/first_launch_service.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/core/theme/theme_service.dart';
import 'package:quietline_app/core/soundscapes/welcome_home_visualization_data.dart';
import 'dart:async';

import '../home/widgets/quiet_home_app_bar.dart';

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
      // 1. Gradient Background
      Container(
        decoration: BoxDecoration(
          gradient: QLGradients.getHomeGradient(
            ThemeService.instance.variant,
          ),
        ),
      ),

      // 2. Animated Halo
      const Center(
        child: _QuietHomeHalo(),
      ),

      // 3. Foreground Content
      SafeArea(
        child: Column(
          children: [
            // Top Bar (Menu only, minimal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding, vertical: kHomeTopSpacing),
              child: QuietHomeAppBar(
                menuKey: menuButtonKey,
                onMenuTap: () => onMenu?.call(),
                onPracticeTap: onPracticeTap, 
              ),
            ),
            
            const Spacer(flex: 3),

            // Affirmation Carousel
            QuietHomeAffirmationsCarousel(
              streak: streak,
            ),

            const SizedBox(height: 12), // Spacing between indicator and bottom area

            const Spacer(flex: 1),
            const SizedBox(height: kHomeBottomSpacing),
          ],
        ),
      ),
      
      //Debug buttons removed
    ],
  );
}

class _QuietHomeHalo extends StatefulWidget {
  const _QuietHomeHalo();

  @override
  State<_QuietHomeHalo> createState() => _QuietHomeHaloState();
}

class _QuietHomeHaloState extends State<_QuietHomeHalo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  double _audioScale = 0.0;
  Timer? _audioTimer;
  int _audioIdx = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.08, end: 0.14).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    SoundscapeService.instance.addListener(_handleSoundscapeChange);
    
    // Check initial state in case audio started before halo was mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleSoundscapeChange();
    });
  }

  void _handleSoundscapeChange() {
    if (SoundscapeService.instance.isWelcomeHomePlaying) {
      if (_audioTimer == null) {
        _startAudioVisualization();
      }
    } else {
      _stopAudioVisualization();
    }
  }

  void _startAudioVisualization() {
    _audioIdx = 0;
    _audioTimer?.cancel();
    
    // We sampled ~240 values over ~45 seconds, so ~185ms per sample
    _audioTimer = Timer.periodic(const Duration(milliseconds: 185), (timer) {
      if (_audioIdx < WelcomeHomeVisualizationData.rmsLevels.length) {
        final rms = WelcomeHomeVisualizationData.rmsLevels[_audioIdx];
        final normalized = WelcomeHomeVisualizationData.normalize(rms);
        
        setState(() {
          _audioScale = normalized;
        });
        _audioIdx++;
      } else {
        _stopAudioVisualization();
      }
    });
  }

  void _stopAudioVisualization() {
    _audioTimer?.cancel();
    _audioTimer = null;
    if (mounted) {
      setState(() {
        _audioScale = 0.0;
      });
    }
  }

  @override
  void dispose() {
    SoundscapeService.instance.removeListener(_handleSoundscapeChange);
    _audioTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth * 0.7;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        // Dark: Teal (#2F6F6B), Light: Soft Blue (#4A90E2)
        final haloColor = isDark ? const Color(0xFF2F6F6B) : const Color(0xFF4A90E2);

        // Combined logic: base animation + audio pulse
        // When audio is playing, _audioScale > 0.
        // We want a smooth blend.
        final baseScale = _scaleAnimation.value;
        final baseOpacity = _opacityAnimation.value;
        
        // Audio effect: increase scale up to +20% and opacity up to +0.2
        final targetScale = baseScale + (_audioScale * 0.2);
        final targetOpacity = (baseOpacity + (_audioScale * 0.15)).clamp(0.0, 0.4);

        return Opacity(
          opacity: targetOpacity,
          child: Transform.scale(
            scale: targetScale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: haloColor,
                boxShadow: [
                  BoxShadow(
                    color: haloColor,
                    blurRadius: 100 + (_audioScale * 40),
                    spreadRadius: 20 + (_audioScale * 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
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
  void initState() {
    super.initState();
    _triggerWelcomeAudio();
  }

  Future<void> _triggerWelcomeAudio() async {
    final ftueCompleted = await FirstLaunchService.instance.hasCompletedFtue();
    if (ftueCompleted) {
      SoundscapeService.instance.playWelcomeHome();
    }
  }

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
