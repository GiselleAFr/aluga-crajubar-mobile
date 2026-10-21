import 'dart:convert';

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
}
