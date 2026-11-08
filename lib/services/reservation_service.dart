import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../home/models/property.dart';
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

  bool get hasCoordinates => latitude != null && longitude != null;
}

/// Uma reserva/solicitação do cliente (tabela bookings).
/// Status da API: pending, confirmed, rejected, cancelled.
class Reservation {
  const Reservation({
    required this.id,
    required this.propertyName,
    required this.guests,
    required this.totalAmount,
    required this.status,
    this.imovelId,
    this.city,
    this.neighborhood,
    this.address,
    this.checkIn,
    this.checkOut,
    this.currency = 'BRL',
    this.landlordName,
    this.landlordPhone,
    this.property,
  });

  final int id;
  final int? imovelId;
  final String propertyName;
  final String? city;
  final String? neighborhood;
  final String? address;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int guests;
  final double totalAmount;
  final String currency;
  final String status;
  final String? landlordName;
  final String? landlordPhone;

  /// Imóvel completo (quando a API envia a relação). Pode ser null.
  final Property? property;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final imovelRaw = json['imovel'];
    final imovel = imovelRaw is Map<String, dynamic> ? imovelRaw : null;
    final donoRaw = imovel?['proprietario'];
    final dono = donoRaw is Map<String, dynamic> ? donoRaw : null;

    final property = (imovel != null && imovel['id'] is num)
        ? Property.fromJson(imovel)
        : null;

    return Reservation(
      id: (json['id'] as num).toInt(),
      imovelId: (json['imovel_id'] as num?)?.toInt(),
      propertyName:
          json['property_name'] as String? ??
          imovel?['titulo'] as String? ??
          'Imóvel',
      city: json['city'] as String? ?? imovel?['cidade'] as String?,
      neighborhood: imovel?['bairro'] as String?,
      address: imovel?['endereco'] as String?,
      checkIn: _parseDate(json['check_in']),
      checkOut: _parseDate(json['check_out']),
      guests: (json['guests'] as num?)?.toInt() ?? 1,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '') ?? 0,
      currency: json['currency'] as String? ?? 'BRL',
      status: json['status'] as String? ?? 'pending',
      landlordName: dono?['name'] as String?,
      landlordPhone: dono?['phone']?.toString(),
      property: property,
    );
  }

  /// Usa só "yyyy-MM-dd" para não deslocar o dia por fuso horário.
  static DateTime? _parseDate(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length < 10) return null;
    return DateTime.tryParse(text.substring(0, 10));
  }

  String get statusLabel => switch (status) {
    'pending' => 'Pendente',
    'confirmed' => 'Confirmada',
    'rejected' => 'Recusada',
    'cancelled' => 'Cancelada',
    _ => status,
  };

  /// O back só permite cancelar antes do dia do check-in.
  bool get canCancel {
    if (status != 'pending' && status != 'confirmed') return false;
    if (checkIn == null) return false;
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return checkIn!.isAfter(hoje);
  }
}

class ReservationService {
  ReservationService({http.Client? client, FlutterSecureStorage? storage})
    : _client = client ?? http.Client(),
      _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_access_token';
  static const _demoToken = 'demo-access-token';

  /// Avisa outras telas (ex.: Home) que as reservas do cliente mudaram
  /// (solicitação criada ou cancelada).
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  final http.Client _client;
  final FlutterSecureStorage _storage;

  void close() => _client.close();

  // ---------------------------------------------------------------------------
  // Solicitar reserva: POST /api/bookings
  // ---------------------------------------------------------------------------
  Future<Reservation> createBooking({
    required int imovelId,
    required String modalidade, // 'diaria' ou 'mensal'
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    final data = await _send(
      'POST',
      '/bookings',
      body: {
        'imovel_id': imovelId,
        'modalidade': modalidade,
        'check_in': _apiDate(checkIn),
        'check_out': _apiDate(checkOut),
        'guests': guests,
      },
    );

    final booking = data['booking'];
    if (booking is! Map<String, dynamic>) {
      throw const ReservationApiException(
        'Resposta inválida ao criar a solicitação.',
      );
    }
    changes.value++;
    return Reservation.fromJson(booking);
  }

  // ---------------------------------------------------------------------------
  // Disponibilidade: GET /api/bookings/disponibilidade
  // ---------------------------------------------------------------------------
  Future<({bool disponivel, String? message})> checkAvailability({
    required int imovelId,
    required String modalidade,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final data = await _send(
      'GET',
      '/bookings/disponibilidade',
      query: {
        'imovel_id': '$imovelId',
        'modalidade': modalidade,
        'check_in': _apiDate(checkIn),
        'check_out': _apiDate(checkOut),
      },
    );
    return (
      disponivel: data['disponivel'] == true,
      message: data['message'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Minhas reservas: GET /api/bookings (percorre todas as páginas)
  // ---------------------------------------------------------------------------
  Future<List<Reservation>> getReservations({String? status}) async {
    final lista = <Reservation>[];
    var page = 1;
    var lastPage = 1;

    do {
      final data = await _send(
        'GET',
        '/bookings',
        query: {'page': '$page', 'per_page': '50', 'status': ?status},
      );

      final items = data['data'];
      if (items is List) {
        lista.addAll(
          items.whereType<Map<String, dynamic>>().map(Reservation.fromJson),
        );
      }

      lastPage = (data['last_page'] as num?)?.toInt() ?? 1;
      page++;
    } while (page <= lastPage && page <= 20);

    return lista;
  }

  // ---------------------------------------------------------------------------
  // Locador: quantidade de solicitações pendentes
  // GET /api/bookings/solicitacoes (somente role landlord)
  // ---------------------------------------------------------------------------
  Future<int> getPendingRequestsCount() async {
    final data = await _send(
      'GET',
      '/bookings/solicitacoes',
      query: {'per_page': '1'},
    );
    return (data['total'] as num?)?.toInt() ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Cancelar: PATCH /api/bookings/{id}/cancelar
  // ---------------------------------------------------------------------------
  Future<Reservation> cancelBooking(int id) async {
    final data = await _send('PATCH', '/bookings/$id/cancelar');
    final booking = data['booking'];
    if (booking is! Map<String, dynamic>) {
      throw const ReservationApiException('Resposta inválida ao cancelar.');
    }
    changes.value++;
    return Reservation.fromJson(booking);
  }

  // ---------------------------------------------------------------------------
  // Hospedagem ativa (já existente)
  // ---------------------------------------------------------------------------
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

    final uri = base.replace(path: '$basePath/auth/profile/active-stay');

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
      throw const ReservationApiException('O servidor demorou para responder.');
    } on http.ClientException {
      throw const ReservationApiException('Não foi possível conectar à API.');
    } on FormatException {
      throw const ReservationApiException(
        'A API retornou uma resposta inválida.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _apiDate(DateTime d) {
    final ano = d.year.toString().padLeft(4, '0');
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      throw const ReservationApiException(
        'Sua sessão expirou. Entre novamente.',
      );
    }
    if (token == _demoToken) {
      throw const ReservationApiException(
        'A conta de demonstração não pode fazer reservas. '
        'Entre com uma conta real.',
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
        if (response.statusCode == 401) {
          await _storage.delete(key: _tokenKey);
          throw const ReservationApiException(
            'Sua sessão expirou. Entre novamente.',
          );
        }
        throw ReservationApiException(_errorMessage(decoded));
      }

      if (decoded is! Map<String, dynamic>) {
        throw const ReservationApiException('Resposta inválida do servidor.');
      }
      return decoded;
    } on ReservationApiException {
      rethrow;
    } on TimeoutException {
      throw const ReservationApiException('O servidor demorou para responder.');
    } on http.ClientException {
      throw const ReservationApiException('Não foi possível conectar à API.');
    } on FormatException {
      throw const ReservationApiException(
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
