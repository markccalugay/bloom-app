import 'package:flutter/material.dart';

class MindfulDaysHeatmap extends StatelessWidget {
  final List<String> sessionDates; // YYYY-MM-DD
  final Color baseTextColor;

  const MindfulDaysHeatmap({
    super.key,
    required this.sessionDates,
    required this.baseTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // We'll show the last 14 weeks (roughly 3.5 months)
    const int weeksToShow = 14;
    
    // Start from the most recent Sunday (or today if it's Sunday) to keep the grid aligned
    final firstDayOfGrid = today.subtract(Duration(days: today.weekday % 7 + (weeksToShow - 1) * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double cellSize = (constraints.maxWidth - (weeksToShow - 1) * 4) / weeksToShow;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(weeksToShow, (weekIndex) {
                return Column(
                  children: List.generate(7, (dayIndex) {
                    final dayDate = firstDayOfGrid.add(Duration(days: weekIndex * 7 + dayIndex));
                    final dateKey = _formatDate(dayDate);
                    final isCompleted = sessionDates.contains(dateKey);
                    final isFuture = dayDate.isAfter(today);

                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : (isFuture
                                ? Colors.transparent
                                : theme.colorScheme.surface),
                        borderRadius: BorderRadius.circular(2),
                        border: isFuture || isCompleted
                            ? null
                            : Border.all(
                                color: baseTextColor.withValues(alpha: 0.05),
                                width: 0.5,
                              ),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Less',
              style: theme.textTheme.bodySmall?.copyWith(
                color: baseTextColor.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
            Row(
              children: [
                _buildLegendCell(theme.colorScheme.surface, theme),
                const SizedBox(width: 4),
                _buildLegendCell(theme.colorScheme.primary, theme),
              ],
            ),
            Text(
              'More',
              style: theme.textTheme.bodySmall?.copyWith(
                color: baseTextColor.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendCell(Color color, ThemeData theme) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
        border: color == theme.colorScheme.surface 
          ? Border.all(color: baseTextColor.withValues(alpha: 0.1), width: 0.5)
          : null,
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
