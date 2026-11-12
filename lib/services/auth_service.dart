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
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.role,
    this.isLandlord = false,
    this.availableTabs = const [],
    this.landlordRequestStatus,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt;
  final String? role;
  final bool isLandlord;
  final List<String> availableTabs;
  final String? landlordRequestStatus;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      role: json['role'] as String?,
      isLandlord: json['is_landlord'] as bool? ?? false,
      availableTabs: (json['available_tabs'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      landlordRequestStatus: json['landlord_request_status'] as String?,
    );
  }
}

class AuthException implements Exception {
  const AuthException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;

  /// Status HTTP da resposta; nulo quando o erro não veio do servidor
  /// (falha de rede, tempo esgotado, resposta inválida).
  final int? statusCode;

  /// Primeira mensagem de cada campo em `errors` (respostas 422 do Laravel).
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

class AuthService {
  static const temporaryLoginEmail = 'demo@alugacrajubar.com';
  static const temporaryLoginPassword = 'Cariri@2026';
  static const _demoAccessToken = 'demo-access-token';

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
    // Conta local apenas para demonstrações em builds de debug.
    if (kDebugMode &&
        email.trim().toLowerCase() == temporaryLoginEmail &&
        password == temporaryLoginPassword) {
      try {
        await _storage.write(key: _tokenKey, value: _demoAccessToken);
      } catch (error) {
        // O login demo deve continuar funcionando mesmo sem keyring no desktop.
        debugPrint('Não foi possível persistir a sessão demo: $error');
      }
      return const AuthUser(
        id: 0,
        name: 'Conta de demonstração',
        email: temporaryLoginEmail,
      );
    }

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
    final token = await _storage.read(key: _tokenKey);
    if (token == _demoAccessToken) {
      return const AuthUser(
        id: 0,
        name: 'Conta de demonstração',
        email: temporaryLoginEmail,
      );
    }

    final data = await _request('GET', '/auth/me', authenticated: true);
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const AuthException('Resposta inválida ao consultar a conta.');
    }
    return AuthUser.fromJson(user);
  }

  /// Atualiza os dados editáveis do perfil: nome e telefone.
  /// O e-mail é único e não pode ser alterado.
  Future<AuthUser> updateProfile({
    required String name,
    required String phone,
  }) async {
    final data = await _request(
      'PATCH',
      '/auth/profile',
      authenticated: true,
      body: {'name': name.trim(), 'phone': phone.trim()},
    );
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const AuthException('Resposta inválida ao atualizar o perfil.');
    }
    return AuthUser.fromJson(user);
  }

  Future<void> logout() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == _demoAccessToken) {
      await _storage.delete(key: _tokenKey);
      return;
    }

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

  /// Solicita a alteração de senha; o servidor envia um código por e-mail.
  Future<String> requestPasswordChange({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _request(
      'POST',
      '/auth/change-password',
      authenticated: true,
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return data['message'] as String? ??
        'Enviamos um e-mail para confirmar a alteração da sua senha.';
  }

  /// Confirma a alteração com o código de 6 dígitos. Em caso de sucesso o
  /// servidor encerra todas as sessões, então o token local também é apagado.
  Future<String> verifyPasswordChangeCode({required String code}) async {
    final data = await _request(
      'POST',
      '/auth/change-password/verify-code',
      authenticated: true,
      body: {'code': code},
    );
    await clearSession();
    return data['message'] as String? ??
        'Senha alterada com sucesso. Faça login novamente.';
  }

  /// Reenvia o código da alteração de senha pendente.
  Future<String> resendPasswordChangeCode() async {
    final data = await _request(
      'POST',
      '/auth/change-password/resend-code',
      authenticated: true,
      body: const <String, dynamic>{},
    );
    return data['message'] as String? ??
        'Enviamos um novo código para o seu e-mail.';
  }

  /// Apaga apenas o token guardado neste aparelho (sem chamar a API).
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {
      // Sem keyring (ex.: desktop): a navegação para o login continua.
    }
  }

  Future<String?> get accessToken => _storage.read(key: _tokenKey);

  void close() => _client.close();

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
    Map<String, String>? queryParameters,
  }) async {
    final base = Uri.parse(apiBaseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final uri = base.replace(
      path: '$basePath$path',
      queryParameters: queryParameters,
    );
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
        throw AuthException(
          _errorMessage(decoded),
          statusCode: response.statusCode,
          fieldErrors: _fieldErrors(decoded),
        );
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

  Map<String, String> _fieldErrors(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return const {};
    return {
      for (final entry in errors.entries)
        if (entry.value is List && (entry.value as List).isNotEmpty)
          entry.key: (entry.value as List).first.toString(),
    };
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