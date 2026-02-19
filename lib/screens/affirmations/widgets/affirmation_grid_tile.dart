import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bloom_app/core/bloom_assets.dart';
import 'package:bloom_app/data/affirmations/affirmations_model.dart';
import 'package:bloom_app/theme/bloom_theme.dart';

class AffirmationGridTile extends StatelessWidget {
  final Affirmation affirmation;
  final bool isUnlocked;
  final bool isPremiumLocked;
  final String lockedLabel;
  final String? unlockedLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLockedTap;

  const AffirmationGridTile({
    super.key,
    required this.affirmation,
    required this.isUnlocked,
    this.isPremiumLocked = false,
    this.lockedLabel = 'Locked',
    this.unlockedLabel,
    this.onTap,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Primary brand text color
    final Color baseTextColor = theme.colorScheme.onSurface;

    final BorderRadius radius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked
            ? onTap
            : () {
                if (onLockedTap != null) {
                  onLockedTap!();
                }
              },
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: theme.colorScheme.surface,
            border: Border.all(
              color: (isDark ? BloomColors.steelGray : BloomColors.skyAsh).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              if (isUnlocked)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            children: [
              // Content (blurred when locked)
              ClipRRect(
                borderRadius: radius,
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.25,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: isUnlocked ? 0 : 8,
                      sigmaY: isUnlocked ? 0 : 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top: small Bloom mark (subtle)
                          Align(
                            alignment: Alignment.topRight,
                            child: SvgPicture.asset(
                              BloomAssets.bloomLogo,
                              width: 12,
                              height: 12,
                              colorFilter: ColorFilter.mode(
                                baseTextColor.withValues(alpha: 0.4),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Center-ish affirmation text
                          Expanded(
                            child: Center(
                              child: Text(
                                affirmation.text,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: baseTextColor.withValues(alpha: 0.9),
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Bottom-left unlocked label
                          if (isUnlocked && unlockedLabel != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              unlockedLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: (isDark ? BloomColors.mutedSand : BloomColors.slateBlue).withValues(alpha: 0.8),
                                fontSize: 9,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // LOCK OVERLAY
              if (!isUnlocked)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (isDark ? BloomColors.midnightBlue : BloomColors.slateBlue).withValues(alpha: 0.8),
                        border: Border.all(
                          color: (isDark ? BloomColors.steelGray : BloomColors.skyAsh).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPremiumLocked
                                ? Icons.workspace_premium_rounded
                                : Icons.lock_outline_rounded,
                            size: 14,
                            color: isDark ? BloomColors.sandWhite : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPremiumLocked ? 'Bloom+' : 'Locked',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark ? BloomColors.sandWhite : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}