import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _kDockHeight = 70.0;          // height of the gray bar (similar to X)
const double _kNavTotalHeight = 120.0;      // total space reserved for nav + overlap
const double _kCenterButtonSize = 75.0;    // Quiet button diameter
const double _kCenterButtonBottomOffset = 25.0; // how far above bottom it sits

/// QuietLine bottom navigation
/// 0 = Home
/// 1 = Quiet session (center)
/// 2 = Brotherhood
class QLBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const QLBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color dockBackground = Color(0xFFD9D9D9); // updated dock background
    const Color activeColor = Color(0xFF111827); // near-black for active icons
    const Color inactiveColor = Color(0xFF6B7280); // muted gray for inactive icons

    return SizedBox(
      height: _kNavTotalHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom dock background + side icons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: _kDockHeight,
              decoration: BoxDecoration(
                color: dockBackground,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: currentIndex == 0,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onItemSelected(0),
                  ),
                  const SizedBox(width: _kCenterButtonSize), // gap under center circle
                  _NavItem(
                    icon: Icons.groups_rounded,
                    label: 'Circle',
                    isActive: currentIndex == 2,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onItemSelected(2),
                  ),
                ],
              ),
            ),
          ),

          // Center QuietLine logo button
          Positioned(
            bottom: _kCenterButtonBottomOffset,
            child: _PrimaryNavItem(
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

/// Center “primary” item – bigger, used to start a Quiet session.
class _PrimaryNavItem extends StatelessWidget {
  final bool isActive;
  final Color activeColor;
  final Color dockBackground;
  final VoidCallback onTap;

  const _PrimaryNavItem({
    required this.isActive,
    required this.activeColor,
    required this.dockBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kCenterButtonSize,
        height: _kCenterButtonSize,
        decoration: BoxDecoration(
          color: dockBackground,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/quietline_logo.svg',
            width: 45,
            height: 45,
          ),
        ),
      ),
    );
  }
}