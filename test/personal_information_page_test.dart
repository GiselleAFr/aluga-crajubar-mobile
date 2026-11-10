import 'package:aluga_crajubar_mobile/profile/personal_information_page.dart';
import 'package:aluga_crajubar_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe os campos de informações pessoais', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PersonalInformationPage(
          authService: AuthService(),
          user: const AuthUser(
            id: 1,
            name: 'Amanda Silva',
            email: 'amanda@email.com',
            phone: '+5588999999999',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Informações Pessoais'), findsOneWidget);
    expect(find.text('Toque para alterar a foto de perfil'), findsOneWidget);
    expect(find.text('Nome Completo'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('CPF'), findsOneWidget);
    expect(find.text('Telefone'), findsOneWidget);

  });
}
