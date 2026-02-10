import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double areaHeight = totalWidth * 0.8;

          return ListenableBuilder(
            listenable: ForgeService.instance,
            builder: (context, _) {
              return Align(
                alignment: const Alignment(0, -0.05),
                child: SizedBox(
                  width: totalWidth,
                  height: areaHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Particles layer
                      const Positioned.fill(
                        child: QuietIngotParticles(),
                      ),
                      
                      // Iron Piece (Restored to center)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SvgPicture.asset(
                          ForgeService.instance.currentAsset,
                          width: totalWidth * 0.5,
                          fit: BoxFit.contain,
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