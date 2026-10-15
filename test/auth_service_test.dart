import 'package:aluga_crajubar_mobile/home/home_page.dart';
import 'package:aluga_crajubar_mobile/login/login/login.dart';
import 'package:aluga_crajubar_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
