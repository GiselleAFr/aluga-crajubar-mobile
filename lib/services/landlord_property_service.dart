import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../landlord/models/landlord_property_address.dart';
import '../landlord/models/landlord_property_draft.dart';
import 'auth_service.dart' show apiBaseUrl;

class LandlordPropertyApiException implements Exception {
  const LandlordPropertyApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

class LandlordPropertyService {
  LandlordPropertyService({
    required this.accessToken,
    http.Client? client,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? apiBaseUrl;

  static const _maxPhotos = 10;
  static const _maxPhotoBytes = 10 * 1024 * 1024;

  final Future<String?> Function() accessToken;
  final http.Client _client;
  final String _baseUrl;

  void close() => _client.close();

  Future<List<LandlordPropertyDraft>> list() async {
    final response = await _requestJson(
      'GET',
      '/landlord/imoveis',
      queryParameters: const {'per_page': '100'},
    );
    final properties = response['data'];
    if (properties is! List) {
      throw const LandlordPropertyApiException(
        'A API retornou uma lista de imóveis inválida.',
      );
    }

    return properties.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const LandlordPropertyApiException(
          'A API retornou um imóvel inválido.',
        );
      }
      return _draftFromJson(item);
    }).toList();
  }

  Future<LandlordPropertyDraft> create(LandlordPropertyDraft property) async {
    final photoUploads = _localPhotos(property.photos);
    _validatePhotoCount(property.photos.length);
    if (photoUploads.isEmpty) {
      throw const LandlordPropertyApiException(
        'Adicione ao menos uma foto para cadastrar o imóvel.',
      );
    }
    _validatePhotoFiles(photoUploads);

    final response = await _requestJson(
      'POST',
      '/imoveis',
      body: _payload(property),
    );
    var data = _propertyData(response);
    final id = _propertyId(data);

    try {
      final uploadResponse = await _uploadPhotos(id, photoUploads);
      data = _propertyData(uploadResponse);
      final uploadedPhotos = _photosFromJson(data);
      final mainPhotoIndex = property.mainPhotoIndex;
      if (mainPhotoIndex < 0 || mainPhotoIndex >= uploadedPhotos.length) {
        throw const LandlordPropertyApiException(
          'A foto principal selecionada não foi enviada.',
        );
      }

      final mainPhoto = uploadedPhotos[mainPhotoIndex];
      if (mainPhoto.id == null) {
        throw const LandlordPropertyApiException(
          'A API não retornou o identificador da foto principal.',
        );
      }

      if (!mainPhoto.isCover) {
        data = _propertyData(
          await _requestJson(
            'PATCH',
            '/imoveis/$id/fotos/${mainPhoto.id}/principal',
          ),
        );
      }

      return _draftFromJson(data);
    } on LandlordPropertyApiException catch (error) {
      try {
        await _requestJson('DELETE', '/imoveis/$id');
      } on LandlordPropertyApiException catch (cleanupError) {
        throw LandlordPropertyApiException(
          'O imóvel foi criado, mas houve uma falha nas fotos e não foi possível '
          'desfazer o cadastro (imóvel $id). ${cleanupError.message}',
          statusCode: cleanupError.statusCode,
          fieldErrors: error.fieldErrors,
        );
      }
      rethrow;
    }
  }

  Future<LandlordPropertyDraft> update(LandlordPropertyDraft property) async {
    final id = property.id;
    if (id == null) {
      throw const LandlordPropertyApiException(
        'Não foi possível identificar o imóvel para edição.',
      );
    }
    _validatePhotoCount(property.photos.length);
    final newPhotos = _localPhotos(property.photos);
    _validatePhotoFiles(newPhotos);

    final before = _propertyData(await _requestJson('GET', '/imoveis/$id'));
    var data = _propertyData(
      await _requestJson('PATCH', '/imoveis/$id', body: _payload(property)),
    );
    final originalPhotos = _photosFromJson(before);
    final desiredRemoteIds = property.photos
        .where((photo) => photo.id != null)
        .map((photo) => photo.id!)
        .toSet();

    for (final photo in originalPhotos) {
      if (photo.id == null || desiredRemoteIds.contains(photo.id)) continue;
      data = _propertyData(
        await _requestJson('DELETE', '/imoveis/$id/fotos/${photo.id}'),
      );
    }

    if (newPhotos.isNotEmpty) {
      data = _propertyData(await _uploadPhotos(id, newPhotos));
    }

    if (property.photos.isEmpty) {
      return _draftFromJson(data);
    }

    final finalPhotos = _photosFromJson(data);
    final selectedPhoto = property.photos[property.mainPhotoIndex];
    int? selectedPhotoId = selectedPhoto.id;

    if (selectedPhotoId == null) {
      final previousIds = originalPhotos.map((photo) => photo.id).toSet();
      final addedPhotos = finalPhotos
          .where((photo) => !previousIds.contains(photo.id))
          .toList();
      final localIndex =
          property.photos
              .take(property.mainPhotoIndex + 1)
              .where((photo) => photo.isLocal)
              .length -
          1;
      if (localIndex < 0 || localIndex >= addedPhotos.length) {
        throw const LandlordPropertyApiException(
          'Não foi possível localizar a nova foto principal enviada.',
        );
      }
      selectedPhotoId = addedPhotos[localIndex].id;
    }

    if (selectedPhotoId == null) {
      throw const LandlordPropertyApiException(
        'A API não retornou o identificador da foto principal.',
      );
    }

    final currentCover = finalPhotos
        .where((photo) => photo.isCover)
        .firstOrNull;
    if (currentCover?.id != selectedPhotoId) {
      data = _propertyData(
        await _requestJson(
          'PATCH',
          '/imoveis/$id/fotos/$selectedPhotoId/principal',
        ),
      );
    }

    return _draftFromJson(data);
  }

  Future<void> delete(int id) async {
    await _requestJson('DELETE', '/imoveis/$id');
  }

  Future<Map<String, dynamic>> _uploadPhotos(
    int propertyId,
    List<LandlordPropertyPhoto> photos,
  ) async {
    _validatePhotoFiles(photos);
    final token = await _requiredToken();
    final request =
        http.MultipartRequest('POST', _uri('/imoveis/$propertyId/fotos'))
          ..headers['Accept'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $token';

    for (var index = 0; index < photos.length; index++) {
      final photo = photos[index];
      final bytes = photo.bytes;
      if (bytes == null) {
        throw const LandlordPropertyApiException(
          'Uma foto selecionada não possui arquivo local.',
        );
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'fotos[]',
          bytes,
          filename: _safeFileName(photo.fileName, index),
        ),
      );
    }

    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      return _decodeResponse(response);
    } on LandlordPropertyApiException {
      rethrow;
    } on TimeoutException {
      throw const LandlordPropertyApiException(
        'O envio das fotos demorou para responder.',
      );
    } on http.ClientException {
      throw const LandlordPropertyApiException(
        'Não foi possível enviar as fotos. Verifique a conexão e tente novamente.',
      );
    } on FormatException {
      throw const LandlordPropertyApiException(
        'A API retornou uma resposta inválida ao enviar as fotos.',
      );
    }
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final token = await _requiredToken();
    final request = http.Request(method, _uri(path, queryParameters))
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        if (body != null) 'Content-Type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));
      return _decodeResponse(await http.Response.fromStream(streamed));
    } on LandlordPropertyApiException {
      rethrow;
    } on TimeoutException {
      throw const LandlordPropertyApiException(
        'O servidor demorou para responder.',
      );
    } on http.ClientException {
      throw const LandlordPropertyApiException(
        'Não foi possível conectar à API. Verifique o endereço e se o servidor está ativo.',
      );
    } on FormatException {
      throw const LandlordPropertyApiException(
        'A API retornou uma resposta inválida.',
      );
    }
  }

  Future<String> _requiredToken() async {
    final token = await accessToken();
    if (token == null || token.isEmpty) {
      throw const LandlordPropertyApiException(
        'Sua sessão expirou. Entre novamente.',
      );
    }
    return token;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const LandlordPropertyApiException(
        'A API retornou uma resposta inválida.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final fieldErrors = _fieldErrors(decoded);
      final message =
          fieldErrors.values.firstOrNull ??
          (decoded['message'] is String
              ? decoded['message'] as String
              : 'Não foi possível concluir a operação com o imóvel.');
      throw LandlordPropertyApiException(
        message,
        statusCode: response.statusCode,
        fieldErrors: fieldErrors,
      );
    }
    return decoded;
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

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(_baseUrl);
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      path: '$basePath$path',
      queryParameters: queryParameters,
    );
  }

  Map<String, dynamic> _payload(LandlordPropertyDraft property) => {
    'titulo': property.name,
    'descricao': property.description,
    'tipo': property.type.apiValue,
    'finalidade': property.purpose.apiValue,
    'periodo_locacao': property.purpose == LandlordPropertyPurpose.rental
        ? property.rentalPeriod?.apiValue
        : null,
    'preco': property.price,
    'cidade': property.address.city,
    'bairro': property.address.neighborhood,
    'endereco': _formattedStreetAddress(property.address),
    'status': property.status.apiValue,
  };

  String _formattedStreetAddress(LandlordPropertyAddress address) => [
    address.street.trim(),
    address.number.trim(),
    address.complement.trim(),
  ].where((part) => part.isNotEmpty).join(', ');

  List<LandlordPropertyPhoto> _localPhotos(
    List<LandlordPropertyPhoto> photos,
  ) => photos.where((photo) => photo.isLocal).toList();

  void _validatePhotoFiles(List<LandlordPropertyPhoto> photos) {
    for (final photo in photos) {
      final bytes = photo.bytes;
      if (bytes == null) {
        throw const LandlordPropertyApiException(
          'Uma foto selecionada não possui arquivo local.',
        );
      }
      if (bytes.lengthInBytes > _maxPhotoBytes) {
        throw const LandlordPropertyApiException(
          'Cada foto deve ter no máximo 10 MB.',
        );
      }
    }
  }

  void _validatePhotoCount(int count) {
    if (count > _maxPhotos) {
      throw const LandlordPropertyApiException(
        'É possível adicionar no máximo 10 fotos.',
      );
    }
  }

  String _safeFileName(String? fileName, int index) {
    final name = fileName?.trim();
    if (name == null || name.isEmpty) return 'foto-${index + 1}.png';
    return name.replaceAll(RegExp(r'[/\\]'), '_');
  }

  Map<String, dynamic> _propertyData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw const LandlordPropertyApiException(
        'A API retornou os dados do imóvel em formato inválido.',
      );
    }
    return data;
  }

  int _propertyId(Map<String, dynamic> data) {
    final id = data['id'];
    if (id is! num) {
      throw const LandlordPropertyApiException(
        'A API não retornou o identificador do imóvel.',
      );
    }
    return id.toInt();
  }

  List<LandlordPropertyPhoto> _photosFromJson(Map<String, dynamic> property) {
    final photos = property['fotos'];
    if (photos is! List) {
      throw const LandlordPropertyApiException(
        'A API retornou a galeria do imóvel em formato inválido.',
      );
    }
    return photos.map((photo) {
      if (photo is! Map<String, dynamic> ||
          photo['id'] is! num ||
          photo['url'] is! String) {
        throw const LandlordPropertyApiException(
          'A API retornou uma foto de imóvel inválida.',
        );
      }
      return LandlordPropertyPhoto.remote(
        id: (photo['id'] as num).toInt(),
        url: photo['url'] as String,
        isCover: photo['is_cover'] == true,
      );
    }).toList();
  }

  LandlordPropertyDraft _draftFromJson(Map<String, dynamic> data) {
    try {
      final photos = _photosFromJson(data);
      final mainPhotoIndex = photos.indexWhere((photo) => photo.isCover);
      final purpose = LandlordPropertyPurpose.fromApi(
        data['finalidade'] as String,
      );
      final periodValue = data['periodo_locacao'] as String?;
      final period = periodValue == null
          ? null
          : LandlordRentalPeriod.fromApi(periodValue);

      if (purpose == LandlordPropertyPurpose.rental && period == null) {
        throw const FormatException(
          'Imóvel para aluguel sem período de locação.',
        );
      }

      return LandlordPropertyDraft(
        id: _propertyId(data),
        name: data['titulo'] as String,
        description: data['descricao'] as String? ?? '',
        address: LandlordPropertyAddress(
          city: data['cidade'] as String? ?? '',
          neighborhood: data['bairro'] as String? ?? '',
          street: data['endereco'] as String? ?? '',
          number: '',
          complement: '',
        ),
        type: LandlordPropertyType.fromApi(data['tipo'] as String),
        purpose: purpose,
        rentalPeriod: period,
        price: double.parse(data['preco'].toString()),
        photos: photos,
        mainPhotoIndex: mainPhotoIndex < 0 ? 0 : mainPhotoIndex,
        status: LandlordPropertyStatus.fromApi(data['status'] as String),
      );
    } on LandlordPropertyApiException {
      rethrow;
    } on FormatException catch (error) {
      throw LandlordPropertyApiException(
        'A API retornou dados inválidos para um imóvel: $error',
      );
    } on TypeError catch (error) {
      throw LandlordPropertyApiException(
        'A API retornou dados inválidos para um imóvel: $error',
      );
    }
  }
}
