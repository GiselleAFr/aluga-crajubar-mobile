import 'dart:convert';
import 'dart:typed_data';

import 'package:aluga_crajubar_mobile/landlord/models/landlord_property_address.dart';
import 'package:aluga_crajubar_mobile/landlord/models/landlord_property_draft.dart';
import 'package:aluga_crajubar_mobile/services/landlord_property_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('loads landlord properties using the authenticated API', () async {
    late http.Request request;
    final service = LandlordPropertyService(
      accessToken: () async => 'landlord-token',
      client: MockClient((incoming) async {
        request = incoming;
        return _jsonResponse({
          'data': [
            _propertyData(
              id: 8,
              photos: [_photoData(id: 21, cover: true), _photoData(id: 22)],
            ),
          ],
        });
      }),
    );

    final properties = await service.list();

    expect(request.url.path, endsWith('/api/landlord/imoveis'));
    expect(request.url.queryParameters['per_page'], '100');
    expect(request.headers['authorization'], 'Bearer landlord-token');
    expect(properties, hasLength(1));
    expect(properties.single.id, 8);
    expect(properties.single.name, 'Casa de exemplo');
    expect(properties.single.mainPhoto?.id, 21);
    expect(properties.single.mainPhoto?.isCover, isTrue);
    expect(properties.single.photos.last.url, 'https://example.test/22.png');

    service.close();
  });

  test(
    'creates a property and uploads its cover using multipart fields',
    () async {
      final requests = <http.BaseRequest>[];
      final service = LandlordPropertyService(
        accessToken: () async => 'landlord-token',
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'POST' &&
              request.url.path.endsWith('/imoveis')) {
            final body = jsonDecode(request.body);
            expect(body['tipo'], 'apartamento');
            expect(body['finalidade'], 'venda');
            expect(body['periodo_locacao'], isNull);
            expect(body['preco'], 250000);
            expect(body['endereco'], 'Rua A, 12, Bloco B');
            expect(request.headers['authorization'], 'Bearer landlord-token');
            return _jsonResponse({'data': _propertyData(id: 31)});
          }

          expect(request.method, 'POST');
          expect(request.url.path, endsWith('/api/imoveis/31/fotos'));
          expect(request.headers['authorization'], 'Bearer landlord-token');
          expect(
            request.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          expect(request.body, contains('name="fotos[]"'));
          expect(request.body, contains('filename="fachada.jpg"'));
          return _jsonResponse({
            'data': _propertyData(
              id: 31,
              purpose: 'venda',
              period: null,
              type: 'apartamento',
              price: '250000.00',
              photos: [_photoData(id: 41, cover: true)],
            ),
          });
        }),
      );

      final property = await service.create(
        LandlordPropertyDraft(
          name: 'Casa de exemplo',
          description: 'Descrição',
          address: const LandlordPropertyAddress(
            city: 'Crato',
            neighborhood: 'Centro',
            street: 'Rua A',
            number: '12',
            complement: 'Bloco B',
          ),
          type: LandlordPropertyType.apartment,
          purpose: LandlordPropertyPurpose.sale,
          rentalPeriod: null,
          price: 250000,
          photos: [
            LandlordPropertyPhoto.local(
              bytes: Uint8List.fromList([1, 2, 3]),
              fileName: 'fachada.jpg',
            ),
          ],
          mainPhotoIndex: 0,
        ),
      );

      expect(requests, hasLength(2));
      expect(property.id, 31);
      expect(property.purpose, LandlordPropertyPurpose.sale);
      expect(property.rentalPeriod, isNull);
      expect(property.mainPhoto?.id, 41);

      service.close();
    },
  );

  test(
    'updates fields, removes deleted photos, uploads new ones, and sets cover',
    () async {
      final requests = <http.BaseRequest>[];
      final service = LandlordPropertyService(
        accessToken: () async => 'landlord-token',
        client: MockClient((request) async {
          requests.add(request);
          final path = request.url.path;

          if (request.method == 'GET') {
            return _jsonResponse({
              'data': _propertyData(
                id: 4,
                photos: [_photoData(id: 5, cover: true), _photoData(id: 6)],
              ),
            });
          }
          if (request.method == 'PATCH' && path == '/api/imoveis/4') {
            return _jsonResponse({
              'data': _propertyData(
                id: 4,
                photos: [_photoData(id: 5, cover: true), _photoData(id: 6)],
              ),
            });
          }
          if (request.method == 'DELETE' && path.endsWith('/fotos/5')) {
            return _jsonResponse({
              'data': _propertyData(
                id: 4,
                photos: [_photoData(id: 6, cover: true)],
              ),
            });
          }
          if (request.headers['content-type']?.startsWith(
                'multipart/form-data',
              ) ??
              false) {
            expect(request.body, contains('name="fotos[]"'));
            return _jsonResponse({
              'data': _propertyData(
                id: 4,
                photos: [_photoData(id: 6, cover: true), _photoData(id: 7)],
              ),
            });
          }
          if (request.method == 'PATCH' &&
              path.endsWith('/fotos/7/principal')) {
            return _jsonResponse({
              'data': _propertyData(
                id: 4,
                photos: [_photoData(id: 6), _photoData(id: 7, cover: true)],
              ),
            });
          }
          throw StateError('Unexpected request: ${request.method} $path');
        }),
      );

      final updated = await service.update(
        LandlordPropertyDraft(
          id: 4,
          name: 'Casa atualizada',
          description: 'Nova descrição',
          address: const LandlordPropertyAddress(
            city: 'Crato',
            neighborhood: 'Centro',
            street: 'Rua Principal',
            number: '10',
            complement: '',
          ),
          type: LandlordPropertyType.house,
          purpose: LandlordPropertyPurpose.rental,
          rentalPeriod: LandlordRentalPeriod.daily,
          price: 300,
          photos: [
            const LandlordPropertyPhoto.remote(
              id: 6,
              url: 'https://example.test/6.png',
              isCover: false,
            ),
            LandlordPropertyPhoto.local(
              bytes: Uint8List.fromList([1, 2, 3]),
              fileName: 'nova.png',
            ),
          ],
          mainPhotoIndex: 1,
        ),
      );

      expect(
        requests.map((request) => '${request.method} ${request.url.path}'),
        [
          'GET /api/imoveis/4',
          'PATCH /api/imoveis/4',
          'DELETE /api/imoveis/4/fotos/5',
          'POST /api/imoveis/4/fotos',
          'PATCH /api/imoveis/4/fotos/7/principal',
        ],
      );
      expect(updated.mainPhoto?.id, 7);
      expect(updated.mainPhoto?.isCover, isTrue);
      expect(updated.photos, hasLength(2));

      service.close();
    },
  );

  test('rejects photos over 10 MB before creating the property', () async {
    var requestSent = false;
    final service = LandlordPropertyService(
      accessToken: () async => 'landlord-token',
      client: MockClient((_) async {
        requestSent = true;
        return _jsonResponse(const {});
      }),
    );

    await expectLater(
      service.create(
        LandlordPropertyDraft(
          name: 'Casa de exemplo',
          description: 'Descrição',
          address: const LandlordPropertyAddress(
            city: 'Crato',
            neighborhood: 'Centro',
            street: 'Rua Principal',
            number: '10',
            complement: '',
          ),
          price: 350,
          photos: [
            LandlordPropertyPhoto.local(bytes: Uint8List(10 * 1024 * 1024 + 1)),
          ],
          mainPhotoIndex: 0,
        ),
      ),
      throwsA(
        isA<LandlordPropertyApiException>().having(
          (error) => error.message,
          'message',
          'Cada foto deve ter no máximo 10 MB.',
        ),
      ),
    );
    expect(requestSent, isFalse);

    service.close();
  });
}

http.Response _jsonResponse(Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _propertyData({
  required int id,
  String type = 'casa',
  String purpose = 'aluguel',
  String? period = 'diaria',
  String price = '350.00',
  List<Map<String, dynamic>> photos = const [],
}) => {
  'id': id,
  'titulo': 'Casa de exemplo',
  'descricao': 'Descrição',
  'tipo': type,
  'finalidade': purpose,
  'periodo_locacao': period,
  'preco': price,
  'cidade': 'Crato',
  'bairro': 'Centro',
  'endereco': 'Rua Principal, 10',
  'status': 'available',
  'fotos': photos,
};

Map<String, dynamic> _photoData({required int id, bool cover = false}) => {
  'id': id,
  'url': 'https://example.test/$id.png',
  'position': id,
  'is_cover': cover,
};
