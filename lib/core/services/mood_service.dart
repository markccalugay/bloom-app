import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class MoodLogEntry {
  final DateTime timestamp;
  final int moodValue; // 1 to 5
  final String? note;

  MoodLogEntry({
    required this.timestamp,
    required this.moodValue,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'moodValue': moodValue,
    'note': note,
  };

  factory MoodLogEntry.fromJson(Map<String, dynamic> json) => MoodLogEntry(
    timestamp: DateTime.parse(json['timestamp']),
    moodValue: json['moodValue'],
    note: json['note'],
  );
}

class MoodService extends ChangeNotifier {
  static final MoodService instance = MoodService._internal();
  MoodService._internal();

  final _storage = const FlutterSecureStorage();
  static const _moodLogsKey = 'bloom_mood_logs_encrypted';

  List<MoodLogEntry> _logs = [];
  List<MoodLogEntry> get logs => List.unmodifiable(_logs);

  Future<void> initialize() async {
    final String? encryptedData = await _storage.read(key: _moodLogsKey);
    if (encryptedData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(encryptedData);
        _logs = decoded.map((item) => MoodLogEntry.fromJson(item)).toList();
      } catch (e) {
        // Handle decoding error or corrupted data
        _logs = [];
      }
    }
    notifyListeners();
  }

  Future<void> logMood(int value, {String? note}) async {
    final entry = MoodLogEntry(
      timestamp: DateTime.now(),
      moodValue: value.clamp(1, 5),
      note: note,
    );
    _logs.add(entry);
    await _saveLogs();
    notifyListeners();
  }

  Future<void> _saveLogs() async {
    final String encoded = jsonEncode(_logs.map((e) => e.toJson()).toList());
    await _storage.write(key: _moodLogsKey, value: encoded);
  }

  List<MoodLogEntry> getLogsForLastWeek() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    return _logs.where((e) => e.timestamp.isAfter(oneWeekAgo)).toList();
  }
}
