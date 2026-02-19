import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bloom_app/core/backup/progress_snapshot.dart';

class BackendService {
  final String baseUrl;

  BackendService({required this.baseUrl});

  Future<void> backup({
    required String idToken,
    required ProgressSnapshot snapshot,
  }) async {
    final url = Uri.parse('$baseUrl/backup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'data': snapshot.toJson(),
          'schema_version': snapshot.schemaVersion,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('BackendService: Backup failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to backup: ${response.body}');
      }
    } catch (e) {
      debugPrint('BackendService: Backup error: $e');
      rethrow;
    }
  }

  Future<ProgressSnapshot?> restore({
    required String idToken,
  }) async {
    final url = Uri.parse('$baseUrl/restore');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('BackendService: Restore failed with status ${response.statusCode}: ${response.body}');
        throw Exception('Failed to restore: ${response.body}');
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['data'] == null) return null;

      return ProgressSnapshot.fromJson(body['data']);
    } catch (e) {
      debugPrint('BackendService: Restore error: $e');
      rethrow;
    }
  }
}
