import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/core/app_assets.dart';
import 'package:quietline_app/theme/ql_theme.dart';

/// Main affirmation card on the Home screen.
class QuietHomeAffirmationsCard extends StatelessWidget {
  final String title;
  final String? unlockedLabel;
  final VoidCallback? onTap;
  final Widget? logo;
  final Gradient? gradient;

  const QuietHomeAffirmationsCard({
    super.key,
    required this.title,
    this.unlockedLabel,
    this.onTap,
    this.logo,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark ? QLColors.sandWhite : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: gradient ?? QLGradients.tealFlame,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Stack(
              children: [
                // Centered affirmation text
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),

                // Bottom-left "unlocked" label
                if (unlockedLabel != null)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text(
                      unlockedLabel!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),

                // Bottom-right icon (QuietLine mark)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    AppAssets.quietlineLogo,
                    width: 14,
                    height: 14,
                    colorFilter: ColorFilter.mode(
                      textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fullscreen affirmation view (MVP).
/// Kept minimal: close button, centered text, and the same footer elements.
class QuietAffirmationFullscreenScreen extends StatelessWidget {
  final String text;
  final String? unlockedLabel;

  const QuietAffirmationFullscreenScreen({
    super.key,
    required this.text,
    this.unlockedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Stack(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: textColor.withValues(alpha: 0.6),
                      tooltip: 'Close',
                      splashRadius: 20,
                    ),
                  ),
                ),

                // Centered affirmation text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer: unlocked label (left) + logo (right)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                    child: Row(
                      children: [
                        if (unlockedLabel != null)
                          Expanded(
                            child: Text(
                              unlockedLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: (isDark ? QLColors.mutedSand : QLColors.slateBlue).withValues(alpha: 0.8),
                              ),
                            ),
                          )
                        else
                          const Spacer(),

                        const SizedBox(width: 12),

                        SvgPicture.asset(
                          AppAssets.quietlineLogo,
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
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
      ),
    );
  }
}
