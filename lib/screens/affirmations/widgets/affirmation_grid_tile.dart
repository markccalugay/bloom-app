import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/core/app_assets.dart';
import 'package:quietline_app/data/affirmations/affirmations_model.dart';

class AffirmationGridTile extends StatelessWidget {
  final Affirmation affirmation;
  final bool isUnlocked;
  final String? unlockedLabel;
  final VoidCallback? onTap;

  const AffirmationGridTile({
    super.key,
    required this.affirmation,
    required this.isUnlocked,
    this.unlockedLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    // Keep tiles visually consistent even when locked.
    final BorderRadius radius = BorderRadius.circular(10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A2228),
                Color(0xFF11171D),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Content (blurred when locked)
              ClipRRect(
                borderRadius: radius,
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.35,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: isUnlocked ? 0 : 6,
                      sigmaY: isUnlocked ? 0 : 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top: small QL mark (subtle)
                          Align(
                            alignment: Alignment.topRight,
                            child: SvgPicture.asset(
                              AppAssets.quietlineLogo,
                              width: 14,
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withValues(alpha: 0.85),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Center-ish affirmation text (trimmed for tile size)
                          Expanded(
                            child: Center(
                              child: Text(
                                affirmation.text,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: baseTextColor.withValues(alpha: 0.95),
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Bottom-left unlocked label (only when unlocked)
                          if (isUnlocked && unlockedLabel != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              unlockedLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 10,
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Locked',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Optional subtle press affordance when unlocked
              if (isUnlocked)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.02),
                            Colors.transparent,
                          ],
                        ),
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