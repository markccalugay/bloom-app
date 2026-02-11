import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quietline_app/core/backup/progress_snapshot.dart';

class BackendService {
  final String baseUrl;

  BackendService({required this.baseUrl});

  Future<void> backup({
    required String idToken,
    required ProgressSnapshot snapshot,
  }) async {
    final url = Uri.parse('$baseUrl/backup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        'data': snapshot.toJson(),
        'schema_version': snapshot.schemaVersion,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to backup: ${response.body}');
    }
  }

  Future<ProgressSnapshot?> restore({
    required String idToken,
  }) async {
    final url = Uri.parse('$baseUrl/restore');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
      }),
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to restore: ${response.body}');
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    if (body['data'] == null) return null;

    return ProgressSnapshot.fromJson(body['data']);
  }
}
