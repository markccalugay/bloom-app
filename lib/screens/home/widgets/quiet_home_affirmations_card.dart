import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/core/app_assets.dart';

/// Main affirmation card on the Home screen.
/// For now it takes plain strings so we don't depend on
/// the Affirmations model/service yet.
class QuietHomeAffirmationsCard extends StatelessWidget {
  final String title;
  final String? unlockedLabel;
  final VoidCallback? onTap;
  final Widget? logo;

  const QuietHomeAffirmationsCard({
    super.key,
    required this.title,
    this.unlockedLabel,
    this.onTap,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2228),
              Color(0xFF11171D),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Stack(
          children: [
            // Centered affirmation text
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Bottom-left "unlocked" label
            if (unlockedLabel != null)
              Positioned(
                left: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    unlockedLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),

            // Bottom-right icon (for "open details" / zoom)
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  AppAssets.quietlineLogo,
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
