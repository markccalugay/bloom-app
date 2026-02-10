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
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth * 1.5;
          final double height = width * 0.35;

          return ListenableBuilder(
            listenable: ForgeService.instance,
            builder: (context, _) {
              return Align(
                alignment: const Alignment(0, -0.10),
                child: SizedBox(
                  width: width,
                  height: height * 1.1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned.fill(
                        child: QuietIngotParticles(),
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: SvgPicture.asset(
                            ForgeService.instance.currentAsset,
                            fit: BoxFit.contain,
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