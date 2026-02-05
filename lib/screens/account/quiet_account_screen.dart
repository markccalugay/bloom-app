import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/core/app_restart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/screens/account/quiet_edit_profile_screen.dart';
import 'package:quietline_app/screens/account/widgets/mindful_days_heatmap.dart';
import 'package:quietline_app/core/entitlements/premium_entitlement.dart';
import 'package:quietline_app/screens/quiet_breath/models/breath_phase_contracts.dart';
import 'package:quietline_app/data/affirmations/affirmations_packs.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'package:quietline_app/screens/paywall/quiet_paywall_screen.dart';

/// Simple MVP account screen.
/// Shows the anonymous user's display name.
class QuietAccountScreen extends StatefulWidget {
  final String reminderLabel;
  final VoidCallback onEditReminder;
  final String currentThemeLabel;
  final VoidCallback onOpenThemeSelection;
  final VoidCallback? onSettingsChanged;

  const QuietAccountScreen({
    super.key,
    required this.reminderLabel,
    required this.onEditReminder,
    required this.currentThemeLabel,
    required this.onOpenThemeSelection,
    this.onSettingsChanged,
  });

  @override
  State<QuietAccountScreen> createState() => _QuietAccountScreenState();
}

class _QuietAccountScreenState extends State<QuietAccountScreen> {
  late final Future<UserProfile> _userFuture;
  late final Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.instance.getOrCreateUser();
    _metricsFuture = _loadMetrics();
  }

  Future<Map<String, dynamic>> _loadMetrics() async {
    final streak = await QuietStreakService.getCurrentStreak();
    final sessions = await QuietStreakService.getTotalSessions();
    final seconds = await QuietStreakService.getTotalSeconds();
    final dates = await QuietStreakService.getSessionDates();
    final usage = await QuietStreakService.getPracticeUsage();
    return {
      'streak': streak,
      'sessions': sessions,
      'seconds': seconds,
      'dates': dates,
      'usage': usage,
    };
  }

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '$mins minutes, $secs seconds';
  }

  Future<void> _handleDataWipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Wipe all data?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will permanently delete your streak, sessions, and preferences. You will be returned to the onboarding screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Wipe Data',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      AppRestart.restart(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.colorScheme.primary;
    final Color baseTextColor = textTheme.bodyMedium?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<UserProfile>(
            future: _userFuture,
            builder: (context, snapshot) {
              // -------- Loading state --------
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // -------- Error state --------
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64),
                    child: Text(
                      'We had trouble loading your account details.\n'
                      'You\'re still anonymous and can use QuietLine as normal.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              final user = snapshot.data!;
              final displayName = user.username;
              final avatarId = user.avatarId;

              // Map avatarId to emoji (shared logic from UserService)
              final emoji = avatarPresets[avatarId] ?? '👤';

              // -------- Normal content --------
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Avatar
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          QLColors.primaryTeal.withValues(alpha: 0.2),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Display name
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // Caption
                    Text(
                      'You’re anonymous to other members.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: baseTextColor.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Edit Profile Button
                    OutlinedButton(
                      onPressed: () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => const QuietEditProfileScreen(),
                          ),
                        );
                        if (updated == true) {
                          if (!context.mounted) return;
                          AppRestart.restart(context); // Simple way to refresh everything
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: baseTextColor.withValues(alpha: 0.1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: baseTextColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ValueListenableBuilder<bool>(
                      valueListenable: StoreKitService.instance.isPremium,
                      builder: (context, isPremium, _) {
                        if (isPremium) return const SizedBox.shrink();
                        return ElevatedButton(
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
                            minimumSize: const Size(200, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Unlock QuietLine+',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    ValueListenableBuilder<bool>(
                      valueListenable: StoreKitService.instance.isPremium,
                      builder: (context, isPremium, _) {
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _metricsFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
                            final metrics = snapshot.data!;
                            final streak = metrics['streak'] as int;
                            final sessions = metrics['sessions'] as int;
                            final seconds = metrics['seconds'] as int;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'METRICS',
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _MetricRow(
                                  label: 'Current Streak',
                                  value: '$streak days',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                _MetricRow(
                                  label: 'Sessions Completed',
                                  value: '$sessions',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                _MetricRow(
                                  label: 'Total Quiet Time',
                                  value: _formatDuration(seconds),
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 12),
                                _MetricRow(
                                  label: 'Affirmations Collected',
                                  value: '${streak > 0 ? streak : 0}/${coreAffirmations.length}',
                                  textColor: baseTextColor,
                                ),
                                const SizedBox(height: 32),

                                // Mindful Days Heatmap
                                Text(
                                  'MINDFUL DAYS',
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: baseTextColor.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: MindfulDaysHeatmap(
                                    sessionDates: metrics['dates'] as List<String>,
                                    baseTextColor: baseTextColor,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Favorite Practices
                                Text(
                                  'FAVORITE PRACTICES',
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    color: baseTextColor.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildFavoritePractices(metrics['usage'] as Map<String, int>, baseTextColor, theme),
                                const SizedBox(height: 48),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // --- PREFERENCES SECTION ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PREFERENCES',
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: baseTextColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _PreferenceTile(
                      icon: Icons.notifications_none_rounded,
                      label: widget.reminderLabel,
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: () {
                        widget.onEditReminder();
                        widget.onSettingsChanged?.call();
                      },
                    ),
                    const SizedBox(height: 12),
                    _PreferenceTile(
                      icon: Icons.palette_outlined,
                      label: widget.currentThemeLabel,
                      iconColor: iconColor,
                      textColor: baseTextColor,
                      onTap: () {
                        widget.onOpenThemeSelection();
                        widget.onSettingsChanged?.call();
                      },
                    ),

                    const SizedBox(height: 48),

                    // --- DATA MANAGEMENT ---
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _handleDataWipe,
                      child: Text(
                        'Data Wipe',
                        style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritePractices(
    Map<String, int> usage,
    Color baseTextColor,
    ThemeData theme,
  ) {
    if (usage.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: baseTextColor.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Text(
            'Start a session to see favorites.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: baseTextColor.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final isPremium = PremiumEntitlement.instance.isPremium;
    final int limit = isPremium ? 3 : 1;

    final sortedUsage = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPractices = sortedUsage.take(limit).toList();

    return Column(
      children: topPractices.map((entry) {
        final practice = allBreathingPractices.firstWhere(
          (p) => p.id == entry.key,
          orElse: () => BreathingPracticeContract(
            id: entry.key,
            name: 'Unknown',
            phases: [],
            cycles: 0,
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _MetricRow(
            label: practice.name,
            value: '${entry.value} times',
            textColor: baseTextColor,
          ),
        );
      }).toList(),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _PreferenceTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: textColor.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: textColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}