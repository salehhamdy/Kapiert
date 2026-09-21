import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/failures.dart';

/// Low-level HTTP client. All API calls go through here.
class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  /// GET request. Returns decoded JSON body on success.
  /// Throws a [Failure] subtype on error.
  Future<Map<String, dynamic>> get(
    String path, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw const NotFoundFailure('Resource not found');
      } else {
        throw NetworkFailure('Server error (${response.statusCode})');
      }
    } on Failure {
      rethrow;
    } on SocketException {
      throw const NetworkFailure(
          'Cannot reach the server. Is the backend running?');
    } on http.ClientException catch (e) {
      throw NetworkFailure('Connection failed: ${e.message}');
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }

  /// GET request returning a JSON list.
  Future<List<dynamic>> getList(
    String path, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw NetworkFailure('Server error (${response.statusCode})');
      }
    } on Failure {
      rethrow;
    } on SocketException {
      throw const NetworkFailure('Cannot reach the server.');
    } catch (e) {
      throw UnexpectedFailure('Unexpected error: $e');
    }
  }

  /// Lightweight health check — returns true if the server responds 200.
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
