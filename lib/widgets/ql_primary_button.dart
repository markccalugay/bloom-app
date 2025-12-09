import 'package:flutter/material.dart';

/// Global primary button used across QuietLine.
///
/// Customize per screen by passing [backgroundColor] and [textColor].
class QLPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry margin;

  const QLPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.margin = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final Color fg = textColor ?? Colors.white;

    return Padding(
      padding: margin,
      child: SizedBox(
        width: 300,
        height: 56, // pill height
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // pill shape
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
