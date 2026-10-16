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

  test('profile and stay history use authenticated API endpoints', () async {
    final storage = FakeSecureStorage();
    await storage.write(key: 'auth_access_token', value: 'test-token');
    final requests = <http.Request>[];
    final service = AuthService(
      storage: storage,
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/auth/profile/stays')) {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 14,
                  'property_name': 'Casa do Centro',
                  'city': 'Crato',
                  'check_in': '2026-08-01',
                  'check_out': '2026-08-05',
                  'guests': 2,
                  'total_amount': '680.00',
                  'currency': 'BRL',
                  'status': 'completed',
                },
              ],
              'meta': {'per_page': 15, 'total': 1},
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'user': {
              'id': 7,
              'name': 'Ana Silva',
              'email': 'ana@example.com',
              'phone': '+5588999991234',
              'role': 'client',
              'is_landlord': false,
              'available_tabs': ['cliente'],
            },
            'completed_stays_count': 3,
          }),
          200,
        );
      }),
    );

    final profile = await service.profile();
    final stays = await service.stayHistory();

    expect(profile.name, 'Ana Silva');
    expect(profile.phone, '+5588999991234');
    expect(profile.completedStaysCount, 3);
    expect(stays.single.propertyName, 'Casa do Centro');
    expect(stays.single.totalAmount, 680);
    expect(requests, hasLength(2));
    expect(requests.first.url.path, endsWith('/api/auth/profile'));
    expect(requests.last.url.path, endsWith('/api/auth/profile/stays'));
    expect(requests.last.url.queryParameters['per_page'], '15');
    expect(requests.first.headers['Authorization'], 'Bearer test-token');
    expect(requests.last.headers['Authorization'], 'Bearer test-token');
  });
}
