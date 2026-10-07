import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final apiBaseUrl = const String.fromEnvironment('API_BASE_URL').isNotEmpty
    ? const String.fromEnvironment('API_BASE_URL')
    : defaultTargetPlatform == TargetPlatform.android
    ? 'http://10.0.2.2:8000/api'
    : 'http://127.0.0.1:8000/api';

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_access_token';
  final http.Client _client;
  final FlutterSecureStorage _storage;

  Future<AuthUser> login({
    required String email,
    required String password,
    required bool remember,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
        'remember': remember,
        'device_name': 'flutter',
      },
    );
    return _saveAuthenticatedResponse(data);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _request(
      'POST',
      '/auth/register',
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': 'flutter',
      },
    );
    return _saveAuthenticatedResponse(data);
  }

  Future<AuthUser> currentUser() async {
    final data = await _request('GET', '/auth/me', authenticated: true);
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const AuthException('Resposta inválida ao consultar a conta.');
    }
    return AuthUser.fromJson(user);
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/auth/logout', authenticated: true);
    } finally {
      await _storage.delete(key: _tokenKey);
    }
  }

  Future<String> requestPasswordReset({required String email}) async {
    final data = await _request(
      'POST',
      '/auth/forgot-password',
      body: {'email': email.trim()},
    );
    return data['message'] as String? ?? 'Verifique seu e-mail.';
  }

  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _request(
      'POST',
      '/auth/reset-password',
      body: {
        'email': email.trim(),
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return data['message'] as String? ?? 'Senha alterada com sucesso.';
  }

  Future<String?> get accessToken => _storage.read(key: _tokenKey);

  Future<AuthUser> _saveAuthenticatedResponse(Map<String, dynamic> data) async {
    final token = data['access_token'];
    final user = data['user'];
    if (token is! String || user is! Map<String, dynamic>) {
      throw const AuthException('Resposta inválida do servidor.');
    }
    await _storage.write(key: _tokenKey, value: token);
    return AuthUser.fromJson(user);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final base = Uri.parse(apiBaseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final uri = base.replace(path: '$basePath$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        throw const AuthException('Sua sessão expirou. Entre novamente.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const AuthException('Resposta inválida do servidor.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 401 && authenticated) {
          await _storage.delete(key: _tokenKey);
        }
        throw AuthException(_errorMessage(decoded));
      }
      return decoded;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException('O servidor demorou para responder.');
    } on http.ClientException {
      throw const AuthException(
        'Não foi possível conectar à API. Verifique o endereço e se o servidor está ativo.',
      );
    } on FormatException {
      throw const AuthException('A API retornou uma resposta inválida.');
    }
  }

  String _errorMessage(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
    }
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    return 'Não foi possível concluir a solicitação.';
  }
}
