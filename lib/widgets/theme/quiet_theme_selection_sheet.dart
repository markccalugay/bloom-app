import 'package:flutter/material.dart';
import '../../theme/ql_theme.dart';
import '../../core/theme/theme_service.dart';

class QuietThemeSelectionSheet extends StatelessWidget {
  const QuietThemeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final currentVariant = ThemeService.instance.variant;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Theme',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...ThemeVariant.values.map((v) {
              final isSelected = v == currentVariant;
              final primaryColor = QLTheme.getPrimaryColor(v);
              final bgColor = QLTheme.getBackgroundColor(v);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  ThemeService.getLabel(v),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                    : null,
                onTap: () async {
                  await ThemeService.instance.setTheme(v);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
