import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:bloom_app/theme/bloom_theme.dart';
import 'package:bloom_app/services/first_launch_service.dart';
import 'package:bloom_app/core/soundscapes/soundscape_service.dart';
import 'package:bloom_app/core/theme/theme_service.dart';
import 'package:bloom_app/core/soundscapes/welcome_home_visualization_data.dart';
import 'dart:async';

import '../home/widgets/bloom_home_app_bar.dart';

const double kHomeHorizontalPadding = 16.0;
const double kHomeTopSpacing = 12.0;          // Tightened from 20.0
const double kHomeBottomSpacing = 8.0;         // Tightened from 16.0

class _BloomHomeHalo extends StatefulWidget {
  const _BloomHomeHalo();

  @override
  State<_BloomHomeHalo> createState() => _BloomHomeHaloState();
}

class _BloomHomeHaloState extends State<_BloomHomeHalo> with SingleTickerProviderStateMixin {
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
    // If the widget tree is locked (e.g. during disposal of another widget that triggered this),
    // we must defer the update.
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleSoundscapeChange();
      });
      return;
    }

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
        
        // Dark: Sage/Brown, Light: Soft Rose/Pink
        final haloColor = theme.colorScheme.primary.withValues(alpha: 0.4);

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


/// Bloom Home screen body.
///
/// NOTE:
/// - This widget does NOT include the bottom navigation bar.
///   That lives in `BloomShellScreen` with `BloomBottomNav`.
class BloomHomeScreen extends StatefulWidget {
  final int streak;
  final VoidCallback? onMenu;
  final VoidCallback? onPracticeTap;
  final GlobalKey? menuButtonKey;

  const BloomHomeScreen({
    super.key,
    required this.streak,
    this.onMenu,
    this.onPracticeTap,
    this.menuButtonKey,
  });

  @override
  State<BloomHomeScreen> createState() => _BloomHomeScreenState();
}

class _BloomHomeScreenState extends State<BloomHomeScreen> {
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
    return Stack(
      children: [
        // 1. Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: BloomGradients.getHomeGradient(
              ThemeService.instance.variant,
            ),
          ),
        ),

        // 2. Animated Halo
        const Center(
          child: _BloomHomeHalo(),
        ),

        // 3. Foreground Content
        SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding, vertical: kHomeTopSpacing),
                child: BloomHomeAppBar(
                  menuKey: widget.menuButtonKey,
                  onMenuTap: () => widget.onMenu?.call(),
                  onPracticeTap: widget.onPracticeTap, 
                ),
              ),
              
              const Spacer(),

              const SizedBox(height: kHomeBottomSpacing),
            ],
          ),
        ),
      ],
    );
  }
}
