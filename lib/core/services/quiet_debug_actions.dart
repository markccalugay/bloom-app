import 'package:flutter/foundation.dart';

class DebugAction {
  final String label;
  final VoidCallback onTrigger;
  final bool isGlobal;

  DebugAction({
    required this.label,
    required this.onTrigger,
    this.isGlobal = false,
  });
}

/// Manages debug actions that can be triggered from the Debug Dock.
class QuietDebugActions extends ChangeNotifier {
  QuietDebugActions._();
  static final QuietDebugActions instance = QuietDebugActions._();

  final Map<String, DebugAction> _globalActions = {};
  final Map<String, DebugAction> _contextualActions = {};

  List<DebugAction> get allActions => [
        ..._contextualActions.values,
        ..._globalActions.values,
      ];

  void registerAction(String label, VoidCallback onTrigger, {bool isGlobal = false}) {
    final action = DebugAction(label: label, onTrigger: onTrigger, isGlobal: isGlobal);
    if (isGlobal) {
      _globalActions[label] = action;
    } else {
      _contextualActions[label] = action;
    }
    notifyListeners();
  }

  void unregisterAction(String label) {
    _globalActions.remove(label);
    _contextualActions.remove(label);
    notifyListeners();
  }

  void clearContextualActions() {
    if (_contextualActions.isEmpty) return;
    _contextualActions.clear();
    notifyListeners();
  }
}
