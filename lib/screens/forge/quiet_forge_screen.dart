import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/theme/ql_theme.dart';
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPreviousAsset() {
    final state = ForgeService.instance.state;
    // We arrived here AFTER advanceProgress was called.
    // So we need to work backwards to see what it was 2 seconds ago.
    
    if (state.ironStage == IronStage.forged) return 'assets/tools/iron_raw.svg';
    if (state.ironStage == IronStage.polished) return 'assets/tools/iron_forged.svg';
    
    // If we're at raw, we might have just unlocked a piece or started over
    if (state.ironStage == IronStage.raw) {
       // If we have pieces, the previous stage was polished (of that piece)
       // But wait, the transition TO raw iron (the next piece's ore)
       // usually happens AFTER the piece is polished.
       return 'assets/tools/iron_polished.svg';
    }

    return 'assets/tools/iron_raw.svg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final forgeState = ForgeService.instance.state;

    String headline = 'The Forge';
    String subheadline = 'Your progress is hardening.';

    if (forgeState.ironStage == IronStage.complete || (forgeState.ironStage == IronStage.raw && forgeState.unlockedPieces.isNotEmpty)) {
       final pieceName = forgeState.unlockedPieces.last.name;
       headline = 'New Piece Unlocked';
       subheadline = 'The $pieceName is ready.';
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
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
                                  colorFilter: ColorFilter.mode(
                                    _controller.isAnimating 
                                        ? QLColors.armorForgeWarm 
                                        : QLColors.armorIronBase,
                                    BlendMode.srcIn,
                                  ),
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
                      label: (forgeState.ironStage == IronStage.raw && forgeState.unlockedPieces.isNotEmpty)
                          ? 'View Armor Room'
                          : 'Return Home',
                      onPressed: () {
                        if (forgeState.ironStage == IronStage.raw && forgeState.unlockedPieces.isNotEmpty) {
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
