

import 'package:flutter/material.dart';

/// Shared copy + actions model
class ReminderPromptActions {
  final VoidCallback onEnable;
  final VoidCallback onLater;

  const ReminderPromptActions({
    required this.onEnable,
    required this.onLater,
  });
}

/// ------------------------------
/// 1) BOTTOM SHEET (recommended)
/// ------------------------------
class ReminderPromptBottomSheet extends StatelessWidget {
  final ReminderPromptActions actions;

  const ReminderPromptBottomSheet({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 12),
            _Body(),
            const SizedBox(height: 20),
            _Actions(actions: actions),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------
/// 2) CENTERED MODAL CARD
/// ------------------------------
class ReminderPromptModalCard extends StatelessWidget {
  final ReminderPromptActions actions;

  const ReminderPromptModalCard({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(centered: true),
            const SizedBox(height: 12),
            _Body(centered: true),
            const SizedBox(height: 20),
            _Actions(actions: actions),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------
/// 3) INLINE HOME CARD
/// ------------------------------
class ReminderPromptInlineCard extends StatelessWidget {
  final ReminderPromptActions actions;

  const ReminderPromptInlineCard({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 8),
            _Body(),
            const SizedBox(height: 12),
            _Actions(actions: actions),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------
/// Shared sub‑widgets
/// ------------------------------
class _Header extends StatelessWidget {
  final bool centered;

  const _Header({this.centered = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Build a daily stillness habit',
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _Body extends StatelessWidget {
  final bool centered;

  const _Body({this.centered = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Would you like a gentle daily reminder to return to Quiet Time?',
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _Actions extends StatelessWidget {
  final ReminderPromptActions actions;

  const _Actions({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: actions.onEnable,
            child: const Text('Set reminder'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: actions.onLater,
          child: const Text('Maybe later'),
        ),
      ],
    );
  }
}