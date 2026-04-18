import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/storage/app_prefs.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? token;
  String? errorMessage;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> loadToken() async {
    token = await AppPrefs.getToken();
    notifyListeners();
  }

  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
    final response = await http.post(
  Uri.parse('${ApiConstants.baseUrl}/Auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'usernameOrEmail': usernameOrEmail,
    'password': password,
  }),
);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final receivedToken =
            data['token'] ??
            data['accessToken'] ??
            data['access_token'] ??
            '';

        if (receivedToken.toString().isEmpty) {
          errorMessage = 'Login thành công nhưng không nhận được token.';
          return false;
        }

        token = receivedToken.toString();
        await AppPrefs.saveToken(token!);
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          errorMessage =
              data['message']?.toString() ??
              data['error']?.toString() ??
              'Đăng nhập thất bại.';
        } catch (_) {
          errorMessage = 'Đăng nhập thất bại. Mã lỗi: ${response.statusCode}';
        }
        return false;
      }
    } catch (e) {
      errorMessage = 'Không kết nối được server: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
  Uri.parse('${ApiConstants.baseUrl}/Auth/register'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': username,
    'email': email,
    'password': password,
  }),
);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          errorMessage =
              data['message']?.toString() ??
              data['error']?.toString() ??
              'Đăng ký thất bại.';
        } catch (_) {
          errorMessage = 'Đăng ký thất bại. Mã lỗi: ${response.statusCode}';
        }
        return false;
      }
    } catch (e) {
      errorMessage = 'Không kết nối được server: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    await AppPrefs.clearToken();
    notifyListeners();
  }
}