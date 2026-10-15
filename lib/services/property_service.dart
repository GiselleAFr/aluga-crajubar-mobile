import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../home/models/property.dart';
import 'auth_service.dart' show apiBaseUrl;

class PropertyApiException implements Exception {
  const PropertyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PropertyService {
  PropertyService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  Future<List<Property>> search({String? query, String? types}) async {
    final base = Uri.parse(apiBaseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final parameters = <String, String>{'per_page': '100'};
    final normalizedQuery = query?.trim();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      parameters['q'] = normalizedQuery;
    }
    if (types != null && types.isNotEmpty) {
      parameters['tipo'] = types;
    }
    final uri = base.replace(
      path: '$basePath/imoveis',
      queryParameters: parameters,
    );

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      final decoded = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['message'] as String?
            : null;
        throw PropertyApiException(
          message ?? 'Não foi possível carregar os imóveis.',
        );
      }
      if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
        throw const PropertyApiException(
          'Resposta inválida da API de imóveis.',
        );
      }
      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Property.fromJson)
          .toList();
    } on PropertyApiException {
      rethrow;
    } on TimeoutException {
      throw const PropertyApiException('O servidor demorou para responder.');
    } on http.ClientException {
      throw const PropertyApiException(
        'Não foi possível conectar à API. Confira o endereço e se o servidor está ativo.',
      );
    } on FormatException {
      throw const PropertyApiException('A API retornou uma resposta inválida.');
    }
  }
}
