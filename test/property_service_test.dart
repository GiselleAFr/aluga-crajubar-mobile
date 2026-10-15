import 'dart:convert';

import 'package:aluga_crajubar_mobile/services/property_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('consulta e converte os imóveis retornados pela API', () async {
    late Uri requestedUri;
    final service = PropertyService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 9,
                'titulo': 'Casa no Centro',
                'tipo': 'casa',
                'preco': '325.50',
                'cidade': 'Crato',
                'bairro': 'Centro',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final properties = await service.search(query: 'Centro', types: 'casa');

    expect(requestedUri.path, endsWith('/api/imoveis'));
    expect(requestedUri.queryParameters['q'], 'Centro');
    expect(requestedUri.queryParameters['tipo'], 'casa');
    expect(requestedUri.queryParameters['per_page'], '100');
    expect(properties, hasLength(1));
    expect(properties.single.nome, 'Casa no Centro');
    expect(properties.single.preco, 325.5);
    expect(properties.single.local, 'Centro, Crato');
    expect(properties.single.imagem, isNull);
    expect(properties.single.nota, isNull);
  });

  test('propaga a mensagem de erro da API', () async {
    final service = PropertyService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'message': 'Serviço indisponível.'}),
          503,
        ),
      ),
    );

    await expectLater(
      service.search(),
      throwsA(
        isA<PropertyApiException>().having(
          (error) => error.message,
          'message',
          'Serviço indisponível.',
        ),
      ),
    );
  });
}
