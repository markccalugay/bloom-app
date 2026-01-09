import 'package:flutter/material.dart';

/// Simple top app bar for the QuietLine Home screen.
/// Currently shows only a hamburger menu on the left.
/// Hook the onMenuTap callback later when the menu is ready.
class QuietHomeAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const QuietHomeAppBar({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            color: color,
            onPressed: onMenuTap ?? () {},
          ),
        ],
      ),
    );
  }
}