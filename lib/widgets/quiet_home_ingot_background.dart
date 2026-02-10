import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/core/app_assets.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/forge/quiet_ingot_particles.dart';

class QuietHomeIngotBackground extends StatefulWidget {
  const QuietHomeIngotBackground({super.key});

  @override
  State<QuietHomeIngotBackground> createState() => _QuietHomeIngotBackgroundState();
}

class _QuietHomeIngotBackgroundState extends State<QuietHomeIngotBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Fade in the iron piece on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive sizing based on width
          final double width = constraints.maxWidth * 0.8;
          final double height = width * 0.6;

          return ListenableBuilder(
            listenable: ForgeService.instance,
            builder: (context, _) {
              return Align(
                alignment: const Alignment(0, -0.05),
                child: SizedBox(
                  width: width,
                  height: height * 1.5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Particles layer
                      const Positioned.fill(
                        child: QuietIngotParticles(),
                      ),
                      
                      // Anvil Backdrop (Reduced size by 45%, 40% opacity)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SvgPicture.asset(
                            AppAssets.anvil,
                            width: width * 0.65, // Slightly larger for better base
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      
                      // Iron Piece sitting on the top edge of the anvil
                      Positioned(
                        bottom: height * 0.42, // Adjusted vertically
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: width * 0.45,
                              child: SvgPicture.asset(
                                ForgeService.instance.currentAsset,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}