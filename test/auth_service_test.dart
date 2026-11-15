import 'dart:convert';
import 'dart:typed_data';

import 'package:aluga_crajubar_mobile/home/home_page.dart';
import 'package:aluga_crajubar_mobile/login/login/login.dart';
import 'package:aluga_crajubar_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _values = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _values.remove(key);
      return;
    }
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _values[key];

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _values.clear();
  }
}

class UnavailableSecureStorage extends FakeSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw StateError('Secure storage indisponível');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo login persists a local session in debug mode', (
    tester,
  ) async {
    final storage = FakeSecureStorage();

    final service = AuthService(storage: storage);

    final user = await service.login(
      email: AuthService.temporaryLoginEmail,
      password: AuthService.temporaryLoginPassword,
      remember: true,
    );

    expect(user.email, AuthService.temporaryLoginEmail);
    expect(await service.accessToken, isNotNull);
    expect(
      (await service.currentUser()).email,
      AuthService.temporaryLoginEmail,
    );
  });

  testWidgets('valid test login opens the home page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          authService: AuthService(storage: UnavailableSecureStorage()),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField).at(0),
      AuthService.temporaryLoginEmail,
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      AuthService.temporaryLoginPassword,
    );
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  test(
    'current user reads profile fields from authenticated /auth/me',
    () async {
      final storage = FakeSecureStorage();
      await storage.write(key: 'auth_access_token', value: 'test-token');
      http.Request? request;
      final service = AuthService(
        storage: storage,
        client: MockClient((incoming) async {
          request = incoming;
          return http.Response(
            jsonEncode({
              'user': {
                'id': 7,
                'name': 'Ana Silva',
                'email': 'ana@example.com',
                'phone': '+5588999991234',
                'created_at': '2024-05-10T12:00:00.000000Z',
                'role': 'client',
                'is_landlord': false,
                'available_tabs': ['cliente'],
              },
            }),
            200,
          );
        }),
      );

      final user = await service.currentUser();

      expect(user.name, 'Ana Silva');
      expect(user.email, 'ana@example.com');
      expect(user.phone, '+5588999991234');
      expect(user.createdAt?.year, 2024);
      expect(user.role, 'client');
      expect(user.availableTabs, ['cliente']);
      expect(request?.url.path, endsWith('/api/auth/me'));
      expect(request?.headers['Authorization'], 'Bearer test-token');
      service.close();
    },
  );

  test('submits landlord request details with authentication', () async {
    final storage = FakeSecureStorage();
    await storage.write(key: 'auth_access_token', value: 'test-token');
    http.Request? request;
    final service = AuthService(
      storage: storage,
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          jsonEncode({
            'message': 'Solicitação enviada.',
            'data': {'status': 'pending'},
          }),
          201,
        );
      }),
    );

    await service.submitLandlordRequest(
      fullName: 'Ana Maria Silva',
      cpf: '529.982.247-25',
      birthDate: DateTime(1990, 11, 8),
      documentType: 'cnh',
      email: ' ana@example.com ',
      primaryPhone: '(88) 99999-1234',
      secondaryPhone: '',
      commercialPhone: '(88) 3333-4444',
      documentFrontBytes: Uint8List.fromList([1, 2, 3]),
      documentFrontFileName: 'frente.png',
      documentBackBytes: Uint8List.fromList([4, 5, 6]),
      documentBackFileName: 'verso.jpeg',
    );

    expect(request?.url.path, endsWith('/api/landlord-request'));
    expect(request?.headers['Authorization'], 'Bearer test-token');
    expect(
      request?.headers['content-type'],
      startsWith('multipart/form-data; boundary='),
    );
    expect(request?.body, contains('name="full_name"'));
    expect(request?.body, contains('Ana Maria Silva'));
    expect(request?.body, contains('name="cpf"'));
    expect(request?.body, contains('529.982.247-25'));
    expect(request?.body, contains('name="birth_date"'));
    expect(request?.body, contains('1990-11-08'));
    expect(
      request?.body,
      contains('name="document_front"; filename="document_front.png"'),
    );
    expect(
      request?.body,
      contains('name="document_back"; filename="document_back.jpeg"'),
    );
    service.close();
  });

  test('demo account cannot submit a landlord request', () async {
    final service = AuthService(
      storage: FakeSecureStorage(),
      client: MockClient((_) async {
        fail('The demo account must not call the API.');
      }),
    );
    await service.login(
      email: AuthService.temporaryLoginEmail,
      password: AuthService.temporaryLoginPassword,
      remember: true,
    );

    await expectLater(
      service.submitLandlordRequest(
        fullName: 'Ana Maria Silva',
        cpf: '529.982.247-25',
        birthDate: DateTime(1990, 11, 8),
        documentType: 'rg',
        email: 'ana@example.com',
        primaryPhone: '(88) 99999-1234',
        secondaryPhone: '',
        commercialPhone: '',
        documentFrontBytes: Uint8List.fromList([1]),
        documentFrontFileName: 'front.png',
        documentBackBytes: Uint8List.fromList([2]),
        documentBackFileName: 'back.png',
      ),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'A conta de demonstração não pode enviar uma solicitação de locador.',
        ),
      ),
    );

    service.close();
  });
}
