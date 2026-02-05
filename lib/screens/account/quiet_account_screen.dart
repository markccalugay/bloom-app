import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/data/user/user_service.dart';

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

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.instance.getOrCreateUser();
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
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 32,
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

                    const SizedBox(height: 8),

                    // Caption
                    Text(
                      'You’re anonymous to other members.\n'
                      'You can customize this later.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: baseTextColor.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 48),

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
                  ],
                ),
              );
            },
          ),
        ),
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