import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/widgets/forge/quiet_ingot_particles.dart';
import 'package:quietline_app/core/app_assets.dart';

import 'package:flutter/services.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';

class QuietHomeIngotBackground extends StatefulWidget {
  const QuietHomeIngotBackground({super.key});

  @override
  State<QuietHomeIngotBackground> createState() => _QuietHomeIngotBackgroundState();
}

class _QuietHomeIngotBackgroundState extends State<QuietHomeIngotBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _fallAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fallAnimation = Tween<Offset>(
      begin: const Offset(0, -4.0), // Start way up high
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut, // Gives it that "thud" feel
    ));

    // If it's raw, show the falling animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ForgeService.instance.state.ironStage == IronStage.raw) {
        _startFall();
      } else {
        _controller.value = 1.0;
      }
    });
  }

  Future<void> _startFall() async {
    // Slight delay before drop starts
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    _controller.forward(from: 0.0);
    
    // Play sound mid-fall/at impact
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    
    await SoundscapeService.instance.playSfx(AppAssets.oreDropSfx);
    HapticFeedback.mediumImpact();
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
                      SlideTransition(
                        position: _fallAnimation,
                        child: Opacity(
                          opacity: 0.55,
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: SvgPicture.asset(
                              ForgeService.instance.currentAsset,
                              fit: BoxFit.contain,
                              colorFilter: const ColorFilter.mode(
                                QLColors.armorIronBase,
                                BlendMode.srcIn,
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