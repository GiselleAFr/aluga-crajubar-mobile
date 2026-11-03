
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart' show apiBaseUrl;

class ReservationApiException implements Exception {
  const ReservationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ActiveStay {
  const ActiveStay({
    required this.id,
    required this.propertyName,
    this.imovelId,
    this.city,
    this.neighborhood,
    this.address,
    this.latitude,
    this.longitude,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.status,
  });

  final int id;
  final int? imovelId;
  final String propertyName;
  final String? city;
  final String? neighborhood;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? guests;
  final String? status;

  factory ActiveStay.fromJson(Map<String, dynamic> json) {
    return ActiveStay(
      id: (json['id'] as num).toInt(),
      imovelId: (json['imovel_id'] as num?)?.toInt(),
      propertyName: json['property_name'] as String? ?? '',
      city: json['city'] as String?,
      neighborhood: json['bairro'] as String?,
      address: json['address'] as String?,
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      checkIn: DateTime.tryParse(json['check_in'] as String? ?? ''),
      checkOut: DateTime.tryParse(json['check_out'] as String? ?? ''),
      guests: (json['guests'] as num?)?.toInt(),
      status: json['status'] as String?,
    );
  }

  bool get hasCoordinates =>
      latitude != null && longitude != null;
}

class ReservationService {
  ReservationService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_access_token';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  void close() => _client.close();

  Future<ActiveStay?> getActiveStay() async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      throw const ReservationApiException(
        'Sua sessão expirou. Entre novamente.',
      );
    }

    final base = Uri.parse(apiBaseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;

    final uri = base.replace(
      path: '$basePath/auth/profile/active-stay',
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['message'] as String?
            : null;

        throw ReservationApiException(
          message ?? 'Não foi possível consultar sua hospedagem.',
        );
      }

      if (decoded is! Map<String, dynamic> ||
          decoded['has_active_stay'] is! bool) {
        throw const ReservationApiException(
          'Resposta inválida da API de hospedagem.',
        );
      }

      if (decoded['has_active_stay'] == false) {
        return null;
      }

      final stay = decoded['stay'];

      if (stay is! Map<String, dynamic>) {
        throw const ReservationApiException(
          'Os dados da hospedagem estão incompletos.',
        );
      }

      return ActiveStay.fromJson(stay);
    } on ReservationApiException {
      rethrow;
    } on TimeoutException {
      throw const ReservationApiException(
        'O servidor demorou para responder.',
      );
    } on http.ClientException {
      throw const ReservationApiException(
        'Não foi possível conectar à API.',
      );
    } on FormatException {
      throw const ReservationApiException(
        'A API retornou uma resposta inválida.',
      );
    }
  }
}
