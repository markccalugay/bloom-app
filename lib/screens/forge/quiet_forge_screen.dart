import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/widgets/forge/quiet_forge_confetti.dart';
import 'package:quietline_app/widgets/forge/quiet_forge_cloud_effect.dart';
import 'package:quietline_app/screens/forge/quiet_armor_room_screen.dart';

class QuietForgeScreen extends StatefulWidget {
  const QuietForgeScreen({super.key});

  @override
  State<QuietForgeScreen> createState() => _QuietForgeScreenState();
}

class _QuietForgeScreenState extends State<QuietForgeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wiggleAnimation;
  bool _showPiece = false;
  bool _transitioned = false; // Whether we've switched to the new asset
  
  final GlobalKey<QuietForgeConfettiState> _confettiKey = GlobalKey();
  final GlobalKey<QuietForgeCloudEffectState> _cloudKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _wiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.05).chain(CurveTween(curve: Curves.easeIn)), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.05, end: -0.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: -0.05, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
    ]).animate(_controller);

    _startForgeSequence();
  }

  Future<void> _startForgeSequence() async {
    // Initial delay to let the user see the "old" state
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Start cloud puff
    _cloudKey.currentState?.show();
    
    // SFX and Haptics happen mid-puff
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Play SFX
    final sfx = ForgeService.instance.getRandomHammerSfx();
    await SoundscapeService.instance.playSfx(sfx);
    
    // Trigger confetti
    _confettiKey.currentState?.burst();

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // "Quick Change": switch asset while covered by cloud
    setState(() {
      _transitioned = true;
      _showPiece = true;
    });

    // Wiggle the new piece as it emerges
    await _controller.forward();
    if (!mounted) return;
    await _controller.reverse();

    // Show explanation if not seen before
    final forgeService = ForgeService.instance;
    if (!forgeService.state.hasSeenExplanation) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      _showExplanationDialog();
    }
  }

  void _showExplanationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text('The Forge', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your consistency applies pressure. Pressure refines iron. Refined iron assembles armor.\n\nShowing up advances your material. Nothing is lost if a day is missed. Your progress waits.',
          style: TextStyle(color: Color(0xFFB9C3CF)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ForgeService.instance.markExplanationSeen();
              Navigator.of(context).pop();
            },
            child: const Text('I understand', style: TextStyle(color: Color(0xFF2FE6D2))),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPreviousAsset() {
    final state = ForgeService.instance.state;
    // We arrived here AFTER advanceProgress was called.
    
    if (state.totalSessions == 1) return 'assets/tools/iron_raw.svg'; // Technically it was nothing or raw
    if (state.totalSessions == 2) return 'assets/tools/iron_raw.svg';
    if (state.totalSessions == 3) return 'assets/tools/iron_ingot.svg';
    
    return 'assets/tools/iron_polished.svg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final forgeState = ForgeService.instance.state;

    String headline = 'The Forge';
    String subheadline = 'Your discipline is refining Iron.';

    if (forgeState.ironStage == IronStage.raw) {
      subheadline = 'Material: Raw Iron';
    } else if (forgeState.ironStage == IronStage.ingot) {
      subheadline = 'Material: Iron Ingot';
    } else if (forgeState.ironStage == IronStage.polished) {
      subheadline = 'Material: Polished Iron Ingot';
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0, // accounting for vertical padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subheadline,
                      style: textTheme.bodyMedium?.copyWith(
                        color: (textTheme.bodyMedium?.color ?? Colors.white).withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Particles/Confetti layer
                          SizedBox(
                            width: 400,
                            height: 400,
                            child: QuietForgeConfetti(
                              key: _confettiKey,
                            ),
                          ),
                          // Piece layer
                          AnimatedBuilder(
                            animation: _wiggleAnimation,
                            builder: (context, child) {
                              final asset = _transitioned 
                                  ? ForgeService.instance.currentAsset 
                                  : _getPreviousAsset();
                              
                              return Transform.rotate(
                                angle: _wiggleAnimation.value,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: (_transitioned || !_showPiece) ? 1.0 : 0.6,
                                  child: SvgPicture.asset(
                                    asset,
                                    width: 280,
                                    height: 280,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Cloud Transition layer (Topmost)
                          SizedBox(
                            width: 500,
                            height: 500,
                            child: QuietForgeCloudEffect(
                              key: _cloudKey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showPiece ? 1.0 : 0.0,
                      child: QLPrimaryButton(
                        label: forgeState.unlockedPieces.isNotEmpty
                            ? 'View Armor Room'
                            : 'Return Home',
                        onPressed: () {
                          if (forgeState.unlockedPieces.isNotEmpty) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const QuietArmorRoomScreen()),
                            );
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const QuietShellScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20), // Extra breathing room above the dock
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
