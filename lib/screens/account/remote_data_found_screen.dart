import 'package:flutter/material.dart';
import 'package:quietline_app/core/auth/user_model.dart';
import 'package:quietline_app/core/backup/backup_coordinator.dart';
import 'package:quietline_app/core/backup/progress_snapshot.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:intl/intl.dart';

class RemoteDataFoundScreen extends StatefulWidget {
  final AuthenticatedUser user;
  final ProgressSnapshot remoteSnapshot;
  final VoidCallback onRestoreCompleted;
  final VoidCallback onKeepLocalCompleted;

  const RemoteDataFoundScreen({
    super.key,
    required this.user,
    required this.remoteSnapshot,
    required this.onRestoreCompleted,
    required this.onKeepLocalCompleted,
  });

  @override
  State<RemoteDataFoundScreen> createState() => _RemoteDataFoundScreenState();
}

class _RemoteDataFoundScreenState extends State<RemoteDataFoundScreen> {
  bool _isLoading = false;
  
  // Local Stats
  int? _localStreak;
  int? _localTotalSeconds;
  DateTime? _localMemberSince;

  @override
  void initState() {
    super.initState();
    _loadLocalStats();
  }

  Future<void> _loadLocalStats() async {
    final streak = await QuietStreakService.getCurrentStreak();
    final totalSeconds = await QuietStreakService.getTotalSeconds();
    final profile = await UserService.instance.getOrCreateUser();
    
    if (mounted) {
      setState(() {
        _localStreak = streak;
        _localTotalSeconds = totalSeconds;
        _localMemberSince = profile.createdAt;
      });
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final minutes = (seconds / 60).floor();
    if (minutes < 60) return '$minutes min';
    final hours = (minutes / 60).floor();
    return '$hours hr';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat.yMMMd().format(date);
  }

  String _formatDateFromMs(int? ms) {
    if (ms == null) return 'Unknown';
    return DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(ms));
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    try {
      await BackupCoordinator.instance.applySnapshot(widget.remoteSnapshot);
      if (mounted) widget.onRestoreCompleted();
    } catch (e) {
      debugPrint('Restore failed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleKeepLocal() async {
    setState(() => _isLoading = true);
    try {
      // Create new snapshot from local data
      final localSnapshot = await BackupCoordinator.instance.createSnapshot();
      final idToken = await widget.user.getIdToken();
      
      if (idToken != null) {
        await BackupCoordinator.instance.backendService.backup(
          idToken: idToken, 
          snapshot: localSnapshot,
        );
      }
      
      if (mounted) widget.onKeepLocalCompleted();
    } catch (e) {
      debugPrint('Keep local failed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sync Conflict'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cloud Save Found',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We found existing data for ${widget.user.email ?? "this account"}. Would you like to restore it or keep your current device data?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Comparison Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context, 
                        title: 'This Device',
                        streak: _localStreak ?? 0,
                        time: _localTotalSeconds ?? 0,
                        memberSince: _formatDate(_localMemberSince),
                        isHighlight: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context, 
                        title: 'Cloud Save',
                        streak: widget.remoteSnapshot.streak,
                        time: widget.remoteSnapshot.totalQuietTimeSeconds,
                        memberSince: _formatDateFromMs(widget.remoteSnapshot.memberSince),
                        isHighlight: true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // RESTORE BUTTON (Primary)
                ElevatedButton(
                  onPressed: _handleRestore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Restore Cloud Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                
                // KEEP LOCAL BUTTON (Secondary)
                OutlinedButton(
                  onPressed: _handleKeepLocal,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: Text(
                    'Keep Local Data (Overwrite Cloud)',
                    style: TextStyle(
                      fontSize: 16, 
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int streak,
    required int time,
    required String memberSince,
    required bool isHighlight,
  }) {
    final theme = Theme.of(context);
    final borderColor = isHighlight 
        ? theme.colorScheme.primary 
        : theme.dividerColor;
    final bgColor = isHighlight
        ? theme.colorScheme.primary.withValues(alpha: 0.05)
        : theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isHighlight ? 2 : 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isHighlight ? theme.colorScheme.primary : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(context, 'Streak', '$streak days'),
          const SizedBox(height: 8),
          _buildStatRow(context, 'Time', _formatDuration(time)),
          const SizedBox(height: 8),
          const Divider(height: 16),
          Text(
            'Since',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
          Text(
            memberSince,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
