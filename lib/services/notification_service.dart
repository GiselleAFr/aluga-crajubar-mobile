import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart' show apiBaseUrl;

class NotificationApiException implements Exception {
  const NotificationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Uma preferência do usuário (ex.: type "push", enabled true).
class NotificationPreference {
  const NotificationPreference({
    required this.type,
    required this.label,
    required this.enabled,
  });

  final String type;
  final String label;
  final bool enabled;

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      enabled: json['enabled'] == true,
    );
  }
}

/// Aviso gravado pelo back (tabela notifications).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    this.title,
    this.message,
  });

  final String id;
  final String type;
  final String? title;
  final String? message;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      type: json['type'] as String? ?? '',
      title: json['title'] as String?,
      message: json['message'] as String?,
    );
  }
}

class NotificationService {
  NotificationService({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_access_token';
  static const _demoToken = 'demo-access-token';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  void close() => _client.close();

  // GET /api/notification-preferences
  Future<List<NotificationPreference>> getPreferences() async {
    final data = await _send('GET', '/notification-preferences');
    return _parsePreferences(data);
  }

  // PATCH /api/notification-preferences
  Future<List<NotificationPreference>> updatePreferences(
    Map<String, bool> changes,
  ) async {
    final data = await _send(
      'PATCH',
      '/notification-preferences',
      body: {
        'preferences': [
          for (final entry in changes.entries)
            {'type': entry.key, 'enabled': entry.value},
        ],
      },
    );
    return _parsePreferences(data);
  }

  // GET /api/notifications?unread=1 (mais recentes primeiro)
  Future<List<AppNotification>> getUnread({int perPage = 20}) async {
    final data = await _send(
      'GET',
      '/notifications',
      query: {'unread': '1', 'per_page': '$perPage'},
    );
    final raw = data['data'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  // PATCH /api/notifications/{id}/read
  Future<void> markAsRead(String id) async {
    await _send('PATCH', '/notifications/$id/read');
  }

  List<NotificationPreference> _parsePreferences(Map<String, dynamic> data) {
    final raw = data['data'] ?? data['preferences'];
    if (raw is! List) {
      throw const NotificationApiException(
        'Resposta inválida das preferências.',
      );
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(NotificationPreference.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      throw const NotificationApiException(
        'Sua sessão expirou. Entre novamente.',
        statusCode: 401,
      );
    }
    if (token == _demoToken) {
      throw const NotificationApiException(
        'A conta de demonstração não recebe notificações.',
      );
    }

    final base = Uri.parse(apiBaseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final uri = base.replace(
      path: '$basePath$path',
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );

    try {
      final request = http.Request(method, uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          if (body != null) 'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);

      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NotificationApiException(
          _errorMessage(decoded),
          statusCode: response.statusCode,
        );
      }

      if (decoded is! Map<String, dynamic>) {
        throw const NotificationApiException('Resposta inválida do servidor.');
      }
      return decoded;
    } on NotificationApiException {
      rethrow;
    } on TimeoutException {
      throw const NotificationApiException('O servidor demorou para responder.');
    } on http.ClientException {
      throw const NotificationApiException('Não foi possível conectar à API.');
    } on FormatException {
      throw const NotificationApiException(
        'A API retornou uma resposta inválida.',
      );
    }
  }

  String _errorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Não foi possível concluir a solicitação.';
  }
}