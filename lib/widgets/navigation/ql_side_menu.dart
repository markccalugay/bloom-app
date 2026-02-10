import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';

/// Slide-in side menu used by the shell.
/// The shell owns the open/close state and passes callbacks down.
Future<String> _getVersionLabel() async {
  final info = await PackageInfo.fromPlatform();
  return 'QuietLine v${info.version} (build ${info.buildNumber})';
}
class QLSideMenu extends StatelessWidget {
  final String displayName;
  final String avatarId;
  final VoidCallback onClose;

  // Navigation callbacks (optional so we can wire them gradually)
  final VoidCallback? onNavigateJourney;
  final VoidCallback? onNavigateBrotherhood;
  final VoidCallback? onNavigatePractices;
  final VoidCallback? onNavigateAffirmations;
  final VoidCallback? onNavigateArmorRoom;
  final VoidCallback? onOpenAccount;

  // MVP toggles
  final bool showBrotherhood;
  final bool showJourney;

  // Support / info callbacks
  final VoidCallback? onOpenAbout;
  final VoidCallback? onOpenWebsite;
  final VoidCallback? onOpenSupport;
  final VoidCallback? onCall988;

  // Legal callbacks
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenWhatsNew;

  final String? debugPremiumLabel;
  final bool highlightArmorRoom;

  const QLSideMenu({
    super.key,
    required this.displayName,
    required this.avatarId,
    required this.onClose,
    this.onNavigateJourney,
    this.onNavigateBrotherhood,
    this.onNavigatePractices,
    this.onNavigateAffirmations,
    this.onNavigateArmorRoom,
    this.onOpenAbout,
    this.onOpenWebsite,
    this.onOpenSupport,
    this.onCall988,
    this.onOpenPrivacy,
    this.onOpenTerms,
    this.onOpenWhatsNew,
    this.onOpenAccount,
    this.showBrotherhood = false,
    this.showJourney = false,
    this.debugPremiumLabel,
    this.highlightArmorRoom = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final Color baseTextColor = textTheme.bodyMedium?.color ?? Colors.white;
    final Color iconColor = theme.colorScheme.primary;

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + close
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onOpenAccount,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                avatarPresets[avatarId] ?? '👤',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName.trim().isNotEmpty
                                        ? displayName.trim()
                                        : 'Quiet guest',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: baseTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Anonymous by default',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: baseTextColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: baseTextColor,
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: baseTextColor.withValues(alpha: 0.08), // very soft divider
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Navigation'),
                    if (showJourney)
                      _MenuItem(
                        icon: Icons.timeline_outlined,
                        label: 'My journey',
                        iconColor: iconColor,
                        textColor: baseTextColor.withValues(alpha: 0.6),
                        enabled: false,
                        trailing: _ComingSoonPill(textTheme: textTheme),
                      ),
                    _MenuItem(
                      icon: Icons.person_rounded,
                      label: 'My account',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenAccount,
                      enabled: !highlightArmorRoom,
                    ),
                    if (showBrotherhood)
                      _MenuItem(
                        icon: Icons.groups_rounded,
                        label: 'Brotherhood',
                        iconColor: iconColor,
                        textColor: baseTextColor,
                        onTap: onNavigateBrotherhood,
                        enabled: !highlightArmorRoom,
                      ),
                    _MenuItem(
                      icon: Icons.self_improvement_rounded,
                      label: 'Practices',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onNavigatePractices,
                      enabled: !highlightArmorRoom,
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Affirmations',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onNavigateAffirmations,
                      enabled: !highlightArmorRoom,
                    ),
                    _MenuItem(
                      icon: Icons.shield_outlined,
                      label: 'Armor Room',
                      iconColor: highlightArmorRoom ? const Color(0xFF2FE6D2) : iconColor,
                      textColor: highlightArmorRoom ? const Color(0xFF2FE6D2) : baseTextColor,
                      onTap: onNavigateArmorRoom,
                      highlighted: highlightArmorRoom,
                    ),

                    const SizedBox(height: 16),
                    const _SectionLabel('Support'),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About QuietLine',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenAbout,
                    ),
                    _MenuItem(
                      icon: Icons.public_rounded,
                      label: 'Visit website',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenWebsite,
                    ),
                    _MenuItem(
                      icon: Icons.mail_outline_rounded,
                      label: 'Help & support',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenSupport,
                    ),
                    _MenuItem(
                      icon: Icons.phone_in_talk_rounded,
                      label: 'Call 988',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onCall988,
                    ),
                    _MenuItem(
                      icon: Icons.history_rounded,
                      label: "What's New",
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenWhatsNew,
                    ),

                    const SizedBox(height: 16),
                    const _SectionLabel('Legal'),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenPrivacy,
                    ),
                    _MenuItem(
                      icon: Icons.gavel_outlined,
                      label: 'Terms of Service',
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: onOpenTerms,
                    ),



                    const SizedBox(height: 16),

                    ValueListenableBuilder<bool>(
                      valueListenable: StoreKitService.instance.isPremium,
                      builder: (context, isPremium, _) {
                        if (isPremium) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const QuietPaywallScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Unlock QuietLine+ Premium',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FutureBuilder<String>(
                        future: _getVersionLabel(),
                        builder: (context, snapshot) {
                          final label = snapshot.data ?? 'QuietLine';
                          return Text(
                            label,
                            style: textTheme.bodySmall?.copyWith(
                              color: baseTextColor.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color baseColor = textTheme.bodySmall?.color ?? Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
          color: baseColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool enabled;
  final bool highlighted;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    this.onTap,
    this.enabled = true,
    this.highlighted = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = enabled && onTap != null;

    final row = Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: isInteractive ? iconColor : iconColor.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isInteractive
                  ? textColor
                  : textColor.withValues(alpha: 0.6),
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    if (!isInteractive) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: row,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: highlighted 
            ? Border.all(color: const Color(0xFF2FE6D2).withValues(alpha: 0.5), width: 1.5)
            : null,
        color: highlighted 
            ? const Color(0xFF2FE6D2).withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: row,
        ),
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  final TextTheme textTheme;

  const _ComingSoonPill({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
      ),
      child: Text(
        'Soon',
        style: textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
