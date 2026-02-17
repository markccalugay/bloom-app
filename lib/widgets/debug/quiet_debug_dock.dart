import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quietline_app/core/services/quiet_logger.dart';
import 'package:quietline_app/core/services/quiet_debug_actions.dart';

/// A global debug overlay that provides access to logs and debug actions.
/// Only visible in debug mode.
class QuietDebugDock extends StatefulWidget {
  final Widget child;

  const QuietDebugDock({super.key, required this.child});

  @override
  State<QuietDebugDock> createState() => _QuietDebugDockState();
}

class _QuietDebugDockState extends State<QuietDebugDock> {
  bool _isOpen = false;
  int _activeTab = 0; // 0 = Logs, 1 = Actions

  void _toggleDock() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_isOpen) _buildOverlay(context),
          _buildToggle(context),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleDock,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.teal.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _isOpen ? '✕' : 'Q',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _activeTab == 0 ? _buildLogsTab() : _buildActionsTab(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _TabButton(
          label: 'LOGS',
          isActive: _activeTab == 0,
          onTap: () => setState(() => _activeTab = 0),
        ),
        const SizedBox(width: 8),
        _TabButton(
          label: 'ACTIONS',
          isActive: _activeTab == 1,
          onTap: () => setState(() => _activeTab = 1),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white54),
          onPressed: () {
            if (_activeTab == 0) {
              QuietLogger.instance.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    return ListenableBuilder(
      listenable: QuietLogger.instance,
      builder: (context, _) {
        final logs = QuietLogger.instance.logs;
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: logs.length,
            separatorBuilder: (_, index) => const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 10,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildLogLevelTag(log.level),
                      ],
                    ),
                    const SizedBox(height: 2),
                    SelectableText(
                      log.message,
                      style: TextStyle(
                        color: _getLogColor(log.level),
                        fontSize: 12,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionsTab() {
    return ListenableBuilder(
      listenable: QuietDebugActions.instance,
      builder: (context, _) {
        final actions = QuietDebugActions.instance.allActions;
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'DEBUG ACTIONS',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions.map((action) => _ActionButton(action: action)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogLevelTag(LogLevel level) {
    final color = _getLogColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.error: return Colors.redAccent;
      case LogLevel.warning: return Colors.orangeAccent;
      case LogLevel.debug: return Colors.blueAccent;
      default: return Colors.white70;
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.teal.withValues(alpha: 0.5) : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.teal : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final DebugAction action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTrigger,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: action.isGlobal 
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: action.isGlobal 
                  ? Colors.white10 
                  : Colors.teal.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            action.label,
            style: TextStyle(
              color: action.isGlobal ? Colors.white70 : Colors.tealAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
