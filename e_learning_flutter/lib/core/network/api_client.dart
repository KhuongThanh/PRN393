import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/api_models.dart';
import '../storage/app_prefs.dart';

class ApiClient {
  const ApiClient();

  Future<dynamic> get(
    String path, {
    bool auth = true,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final response = await http.get(uri, headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);
    final response = await http.post(
      uri,
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path);
    final response = await http.put(
      uri,
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final uri = _buildUri(path);
    final response = await http.delete(
      uri,
      headers: await _headers(auth: auth),
    );
    return _handleResponse(response);
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final base = Uri.parse('${ApiConstants.baseUrl}$normalized');
    if (queryParameters == null || queryParameters.isEmpty) {
      return base;
    }
    return base.replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (auth) {
      final token = await AppPrefs.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.trim();
    final parsed = body.isEmpty ? null : _tryDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return parsed;
    }

    throw ApiException(
      message: _extractErrorMessage(parsed, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractErrorMessage(dynamic parsed, int statusCode) {
    if (parsed is Map<String, dynamic>) {
      final message =
          parsed['message']?.toString() ??
          parsed['Message']?.toString() ??
          parsed['error']?.toString() ??
          parsed['Error']?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (parsed is String && parsed.isNotEmpty) {
      return parsed;
    }

    return 'Request failed with status code $statusCode.';
  }
}
