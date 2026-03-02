import 'package:flutter/material.dart';
import 'package:bloom_app/core/services/mood_service.dart';

class MoodReflectionSection extends StatelessWidget {
  final Color baseTextColor;

  const MoodReflectionSection({
    super.key,
    required this.baseTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOOD REFLECTION',
          style: textTheme.labelSmall?.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: baseTextColor.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: baseTextColor.withValues(alpha: 0.08),
            ),
          ),
          child: ListenableBuilder(
            listenable: MoodService.instance,
            builder: (context, _) {
              final logs = MoodService.instance.getLogsForLastWeek();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMoodTrendGraph(theme, logs),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMostCalmDay(theme, logs)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStressReductionMetric(theme, logs)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrendGraph(ThemeData theme, List<MoodLogEntry> logs) {
    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Keep practicing to see your mood trends.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final currentWeekday = now.weekday; 
    
    final moodByDay = List.generate(7, (_) => <int>[]);
    for (final log in logs) {
      final dayIndex = log.timestamp.weekday - 1; 
      moodByDay[dayIndex].add(log.moodValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final avgMood = moodByDay[i].isEmpty 
                ? 0.0 
                : moodByDay[i].reduce((a, b) => a + b) / moodByDay[i].length;
            
            final isCurrentDay = i == (currentWeekday - 1);

            return Column(
              children: [
                Container(
                  height: 100,
                  width: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentDay ? theme.colorScheme.primary.withValues(alpha: 0.4) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (avgMood > 0)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: avgMood * 20, 
                          width: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.6),
                                theme.colorScheme.primary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dayLabels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isCurrentDay ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMostCalmDay(ThemeData theme, List<MoodLogEntry> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    final moodByDay = List.generate(7, (_) => <int>[]);
    for (final log in logs) {
      moodByDay[log.timestamp.weekday - 1].add(log.moodValue);
    }

    double maxMood = -1;
    int bestDayIndex = -1;

    for (int i = 0; i < 7; i++) {
       if (moodByDay[i].isNotEmpty) {
         final avg = moodByDay[i].reduce((a, b) => a + b) / moodByDay[i].length;
         if (avg > maxMood) {
           maxMood = avg;
           bestDayIndex = i;
         }
       }
    }

    if (bestDayIndex == -1) return const SizedBox.shrink();

    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return Row(
      children: [
        Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Most Calm Day',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              dayNames[bestDayIndex],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStressReductionMetric(ThemeData theme, List<MoodLogEntry> logs) {
    if (logs.length < 2) return const SizedBox.shrink();

    // Sort logs by time (should already be somewhat sorted but let's be sure)
    final sortedLogs = List<MoodLogEntry>.from(logs);
    sortedLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Compare average of first 3 entries vs last 3 entries
    final firstCount = sortedLogs.length >= 3 ? 3 : sortedLogs.length ~/ 2;
    if (firstCount == 0) return const SizedBox.shrink();

    final firstAvg = sortedLogs.take(firstCount).map((e) => e.moodValue).reduce((a, b) => a + b) / firstCount;
    final lastAvg = sortedLogs.reversed.take(firstCount).map((e) => e.moodValue).reduce((a, b) => a + b) / firstCount;

    // "Reduction" actually means current mood (lastAvg) is higher than starting mood (firstAvg)
    // Formula: ((last - first) / first) * 100
    // We'll call this the "Bloom Effect"
    final delta = ((lastAvg - firstAvg) / firstAvg) * 100;
    final displayDelta = delta.clamp(0.0, 1000.0).toStringAsFixed(0);

    return Row(
      children: [
        Icon(Icons.trending_up_rounded, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bloom Effect',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '+$displayDelta%',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
