import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:bloom_app/theme/bloom_theme.dart';
import 'package:bloom_app/widgets/affirmations/bloom_home_affirmations_carousel.dart';
import 'package:bloom_app/services/first_launch_service.dart';
import 'package:bloom_app/core/soundscapes/soundscape_service.dart';
import 'package:bloom_app/core/theme/theme_service.dart';
import 'package:bloom_app/core/soundscapes/welcome_home_visualization_data.dart';
import 'dart:async';

import '../home/widgets/bloom_home_app_bar.dart';
import 'package:bloom_app/core/services/user_preferences_service.dart';
import 'package:bloom_app/screens/practice/models/custom_session_config.dart';
import 'package:bloom_app/screens/bloom_breath/models/breath_phase_contracts.dart';
import 'package:bloom_app/screens/bloom_breath/bloom_breath_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:bloom_app/core/soundscapes/soundscape_models.dart';
import 'package:bloom_app/screens/account/mixes/my_mixes_screen.dart';

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


/// Bloom Home screen body.
///
/// NOTE:
/// - This widget does NOT include the bottom navigation bar.
///   That lives in `BloomShellScreen` with `BloomBottomNav`.
/// - For now it only needs the current streak; affirmations
///   are stubbed with a placeholder string.
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
              
              // Custom Mixes Section
              _buildMixesSection(context),

              const Spacer(flex: 3),

              // Affirmation Carousel
              BloomHomeAffirmationsCarousel(
                streak: widget.streak,
              ),

              const SizedBox(height: 12),

              const Spacer(flex: 1),
              const SizedBox(height: kHomeBottomSpacing),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMixesSection(BuildContext context) {
    return ListenableBuilder(
      listenable: UserPreferencesService.instance,
      builder: (context, _) {
        final mixes = UserPreferencesService.instance.customMixes;
        
        // Check for intro
        if (!UserPreferencesService.instance.hasSeenMixIntro) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showMixIntro(context));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyMixesScreen()),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MY MIXES', 
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded, 
                          size: 18, 
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showMixIntro(context),
                    child: Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: mixes.isEmpty 
               ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
                    child: Text(
                      'Create mixes in Account > My Mixes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ),
                )
               : ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kHomeHorizontalPadding),
                children: [
                  ...mixes.map((mix) => _buildMixCard(context, mix)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showMixIntro(BuildContext context) {
    // Prevent double showing if triggered rapidly
    if (ModalRoute.of(context)?.isCurrent != true) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A29), // Dark slate/teal
        title: const Text('Introducing Mixes', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your personal practice, your way.',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Mixes allow you to combine any breathing pattern with any soundscape, for a duration of your choice.\n\nSave your favorites for quick access right here on the Home screen.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              UserPreferencesService.instance.setHasSeenMixIntro();
              Navigator.of(ctx).pop();
            },
            child: const Text('Got it', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMixCard(BuildContext context, CustomSessionConfig mix) {
    return GestureDetector(
      onTap: () => _handleMixTap(context, mix),
      // Long press removed as per design
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mix.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  '${mix.durationSeconds ~/ 60}m',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMixTap(BuildContext context, CustomSessionConfig mix) {
    final soundscape = allSoundscapes.firstWhere(
      (s) => s.id == mix.soundscapeId,
      orElse: () => allSoundscapes.first,
    );
    SoundscapeService.instance.setSoundscape(soundscape);

    final basePractice = allBreathingPractices.firstWhere(
      (p) => p.id == mix.breathPatternId,
      orElse: () => allBreathingPractices.first,
    );

    int cycleDuration = 0;
    for (var phase in basePractice.phases) {
      cycleDuration += phase.seconds;
    }
    final cycles = (mix.durationSeconds / cycleDuration).round();

    final customContract = BreathingPracticeContract(
      id: basePractice.id,
      name: basePractice.name,
      phases: basePractice.phases,
      cycles: cycles,
      isAdvanced: basePractice.isAdvanced,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BloomBreathScreen(
          sessionId: const Uuid().v4(),
          contract: customContract,
        ),
      ),
    );
  }
}
