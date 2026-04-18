import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/storage/app_prefs.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? token;
  String? errorMessage;

  bool get isLoggedIn => token?.isNotEmpty ?? false;

  Future<void> loadToken() async {
    token = await AppPrefs.getToken();
    notifyListeners();
  }

  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) {
    return _authenticate(
      endpoint: '/Auth/login',
      body: {'usernameOrEmail': usernameOrEmail, 'password': password},
    );
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
  }) {
    return _authenticate(
      endpoint: '/Auth/register',
      body: {'username': username, 'email': email, 'password': password},
    );
  }

  Future<bool> _authenticate({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = _tryDecodeJson(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final receivedToken = _extractToken(data);

        if (receivedToken.isEmpty) {
          errorMessage =
              'Xac thuc thanh cong nhung khong nhan duoc token tu server.';
          return false;
        }

        token = receivedToken;
        await AppPrefs.saveToken(token!);
        return true;
      }

      errorMessage = _extractErrorMessage(data, response.statusCode);
      return false;
    } catch (e) {
      errorMessage = 'Khong ket noi duoc toi server: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _tryDecodeJson(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String _extractToken(Map<String, dynamic>? data) {
    if (data == null) {
      return '';
    }

    final dynamic receivedToken =
        data['token'] ??
        data['Token'] ??
        data['accessToken'] ??
        data['access_token'];

    return receivedToken?.toString() ?? '';
  }

  String _extractErrorMessage(Map<String, dynamic>? data, int statusCode) {
    final message =
        data?['message']?.toString() ??
        data?['Message']?.toString() ??
        data?['error']?.toString() ??
        data?['Error']?.toString();

    if (message != null && message.trim().isNotEmpty) {
      return message;
    }

    return 'Yeu cau that bai. Ma loi: $statusCode';
  }

  Future<void> logout() async {
    token = null;
    errorMessage = null;
    await AppPrefs.clearToken();
    notifyListeners();
  }
}
