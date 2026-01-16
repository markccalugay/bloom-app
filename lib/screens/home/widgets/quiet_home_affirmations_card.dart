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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
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
          child: Padding(
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

                // Bottom-right icon (QuietLine mark)
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

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A2228),
                Color(0xFF11171D),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Stack(
              children: [
                // Close button (quiet + consistent tap target)
                Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.white.withValues(alpha: 0.85),
                      tooltip: 'Close',
                      splashRadius: 20,
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                ),

                // Centered affirmation text (constrained width + better rhythm)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer: unlocked label (left) + logo (right)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        if (unlockedLabel != null)
                          Expanded(
                            child: Text(
                              unlockedLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
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
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
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
