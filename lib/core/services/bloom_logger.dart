import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error, debug }

class LogEntry {
  final DateTime timestamp;
  final String message;
  final LogLevel level;

  LogEntry({
    required this.message,
    this.level = LogLevel.info,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// A centralized logger that captures logs for the Debug Dock.
/// This will be hooked into Zone or debugPrint depending on requirements.
class BloomLogger extends ChangeNotifier {
  BloomLogger._();
  static final BloomLogger instance = BloomLogger._();

  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => List.unmodifiable(_logs);

  static const int _maxLogs = 500;

  void log(String message, {LogLevel level = LogLevel.info}) {
    final entry = LogEntry(message: message, level: level);
    _logs.insert(0, entry);
    
    if (_logs.length > _maxLogs) {
      _logs.removeLast();
    }
    
    notifyListeners();
  }

  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message) => log(message, level: LogLevel.error);
  void debug(String message) => log(message, level: LogLevel.debug);

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  /// Redirects global debugPrint to our logger.
  void setupGlobalRedirect() {
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        log(message, level: LogLevel.debug);
      }
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };
  }
}
