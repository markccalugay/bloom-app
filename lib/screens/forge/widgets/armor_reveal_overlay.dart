import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/forge/quiet_forge_confetti.dart';

/// A fullscreen overlay that reveals an unlocked armor piece with confetti and SFX.
class ArmorRevealOverlay extends StatefulWidget {
  final ArmorSet set;
  final ArmorPiece piece;
  final VoidCallback onFinish;

  const ArmorRevealOverlay({
    super.key,
    required this.set,
    required this.piece,
    required this.onFinish,
  });

  @override
  State<ArmorRevealOverlay> createState() => _ArmorRevealOverlayState();
}

class _ArmorRevealOverlayState extends State<ArmorRevealOverlay> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  
  final GlobalKey<QuietForgeConfettiState> _confettiKey = GlobalKey();
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeIn), // Faster fade
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 1.15) // Start smaller for more "explosion" feel
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
    ]).animate(_controller);

    _startReveal();
  }

  Future<void> _startReveal() async {
    // Start reveal animation immediately when _startReveal is called
    // so it's already progressing when confetti pops
    _controller.forward();
    
    // Play SFX (reuse hammer/anvil as requested)
    await SoundscapeService.instance.playSfx(ForgeService.instance.getRandomHammerSfx());
    
    // Haptics (Heavy as requested)
    HapticFeedback.heavyImpact();
    
    // Confetti burst
    _confettiKey.currentState?.burst();

    // Secondary haptics and SFX for impact feel
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
       HapticFeedback.mediumImpact();
    }

    // Wait for the reveal to be admired
    await Future.delayed(const Duration(milliseconds: 2200));

    // Start fade out sequence
    if (mounted) {
      setState(() => _isFadingOut = true);
    }
    
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      widget.onFinish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = ForgeService.instance.getPieceAsset(widget.set, widget.piece);
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: _isFadingOut ? 0.0 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              const Color(0xFF1B232E).withValues(alpha: 0.95), // Lighter center
              Colors.black.withValues(alpha: 0.98), // Darker edges
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
            // Confetti layer
            SizedBox.expand(
              child: QuietForgeConfetti(key: _confettiKey),
            ),
            
            // Piece Reveal
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      asset,
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'NEW ARMOR UNLOCKED',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPieceName(widget.piece).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _getPieceName(ArmorPiece piece) {
    switch (piece) {
      case ArmorPiece.helmet: return 'Helmet';
      case ArmorPiece.tool: return 'Tool';
      case ArmorPiece.pauldrons: return 'Pauldrons';
      case ArmorPiece.chestplate: return 'Chestplate';
    }
  }
}
