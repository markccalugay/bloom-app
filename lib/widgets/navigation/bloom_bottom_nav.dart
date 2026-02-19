import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bloom_app/core/bloom_assets.dart';

const double _kNavTotalHeight = 160.0;      // Increased to accommodate larger button/offset
const double _kCenterButtonSize = 90.0;    // Increased from 75.0 (~20%)
const double _kCenterButtonBottomOffset = 60.0; // Increased from 25.0 to move it up

/// Bloom bottom navigation (MVP)
/// Only the center button is interactive.
/// onItemSelected(1) starts a Bloom session.
class BloomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final GlobalKey bloomTimeButtonKey;

  const BloomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.bloomTimeButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color dockBackground = theme.brightness == Brightness.dark
        ? const Color(0xFF132B34) // Matches Home Dark Gradient bottom
        : const Color(0xFFE2E6EA); // Matches Home Light Gradient bottom
    final Color activeColor = theme.colorScheme.primary;

    return SizedBox(
      height: _kNavTotalHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom dock background removed.

          // Center Bloom logo button
          Positioned(
            bottom: _kCenterButtonBottomOffset,
            child: _PrimaryNavItem(
              containerKey: bloomTimeButtonKey,
              isActive: currentIndex == 1,
              activeColor: activeColor,
              dockBackground: dockBackground,
              onTap: () => onItemSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Side items: icon + label
// ignore: unused_element
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Icon(icon, size: 24, color: color),
      ),
    );
  }
}

/// Center “primary” item – bigger, used to start a Bloom session.
class _PrimaryNavItem extends StatelessWidget {
  final Key? containerKey;
  final bool isActive;
  final Color activeColor;
  final Color dockBackground;
  final VoidCallback onTap;

  const _PrimaryNavItem({
    this.containerKey,
    required this.isActive,
    required this.activeColor,
    required this.dockBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: _kCenterButtonSize,
      height: _kCenterButtonSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          key: containerKey,
          decoration: BoxDecoration(
            color: dockBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              BloomAssets.bloomLogo,
              width: 45,
              height: 45,
              colorFilter: ColorFilter.mode(
                activeColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}