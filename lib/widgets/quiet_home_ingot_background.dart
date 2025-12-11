import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/core/app_assets.dart';

class QuietHomeIngotBackground extends StatelessWidget {
  const QuietHomeIngotBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Size relative to screen width so it scales nicely
          final double width = constraints.maxWidth * 0.55;
          final double height = width * 0.35; // keep your ingot proportions

          return Align(
            // Slightly above center, tweak if needed
            alignment: const Alignment(0, -0.10),
            child: Opacity(
              opacity: 0.25, // matches your current design
              child: SizedBox(
                width: width,
                height: height,
                child: SvgPicture.asset(
                  AppAssets.ingot,        // assets/images/icon-ingot.svg
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}