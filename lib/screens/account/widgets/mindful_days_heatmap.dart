import 'package:flutter/material.dart';

class MindfulDaysHeatmap extends StatelessWidget {
  final Map<String, int> sessionCounts; // YYYY-MM-DD -> count
  final Color baseTextColor;

  const MindfulDaysHeatmap({
    super.key,
    required this.sessionCounts,
    required this.baseTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // We'll show the last 14 weeks
    const int weeksToShow = 14;
    
    // Start from the most recent Sunday (or today if it's Sunday)
    final firstDayOfGrid = today.subtract(Duration(days: today.weekday % 7 + (weeksToShow - 1) * 7));

    final List<String> weekLabels = _generateWeekLabels(firstDayOfGrid, weeksToShow);
    final List<String> dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Adjust constraints for day labels on the left
            const double dayLabelWidth = 30;
            const double spacing = 4;
            final double availableWidth = constraints.maxWidth - dayLabelWidth - spacing;
            final double cellSize = (availableWidth - (weeksToShow - 1) * spacing) / weeksToShow;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Labels Column
                Padding(
                  padding: const EdgeInsets.only(top: 20), // Align with grid rows (below week labels)
                  child: Column(
                    children: dayLabels.asMap().entries.map((e) {
                      final isEven = e.key % 2 == 1; // Mon, Wed, Fri usually labels in GitHub
                      return Container(
                        height: cellSize + 4, // 4 is vertical margin (2+2)
                        width: dayLabelWidth,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isEven ? e.value : '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: baseTextColor.withValues(alpha: 0.4),
                            fontSize: 9,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: spacing),
                // Main Grid + Week Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Week Labels Row
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: List.generate(weeksToShow, (i) {
                            return Expanded(
                              child: Text(
                                weekLabels[i],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: baseTextColor.withValues(alpha: 0.4),
                                  fontSize: 9,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ),
                      ),
                      // The Heatmap Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(weeksToShow, (weekIndex) {
                          return Column(
                            children: List.generate(7, (dayIndex) {
                              final dayDate = firstDayOfGrid.add(Duration(days: weekIndex * 7 + dayIndex));
                              final dateKey = _formatDate(dayDate);
                              final count = sessionCounts[dateKey] ?? 0;
                              final isCompleted = count > 0;
                              final isFuture = dayDate.isAfter(today);

                              return Container(
                                width: cellSize,
                                height: cellSize,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? theme.colorScheme.primary.withValues(alpha: _calculateOpacity(count))
                                      : (isFuture
                                          ? Colors.transparent
                                          : baseTextColor.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: theme.textTheme.bodySmall?.copyWith(
                color: baseTextColor.withValues(alpha: 0.4),
                fontSize: 9,
              ),
            ),
            const SizedBox(width: 4),
            Row(
              children: [0, 1, 2, 3, 4].map((level) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: level == 0 
                      ? baseTextColor.withValues(alpha: 0.05)
                      : theme.colorScheme.primary.withValues(alpha: _calculateOpacity(level)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 7),
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

  double _calculateOpacity(int count) {
    if (count <= 0) return 0.05;
    if (count == 1) return 0.3;
    if (count == 2) return 0.5;
    if (count == 3) return 0.7;
    return 1.0;
  }

  List<String> _generateWeekLabels(DateTime startDate, int weeks) {
    final List<String> labels = [];
    String lastMonth = '';
    for (int i = 0; i < weeks; i++) {
      final date = startDate.add(Duration(days: i * 7));
      final month = _getMonthAbbreviation(date.month);
      if (month != lastMonth) {
        labels.add(month);
        lastMonth = month;
      } else {
        labels.add('');
      }
    }
    return labels;
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
