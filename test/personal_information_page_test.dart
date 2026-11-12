import 'package:aluga_crajubar_mobile/profile/personal_information_page.dart';
import 'package:aluga_crajubar_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe os campos de informações pessoais', (tester) async {
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
    expect(find.text('Telefone'), findsOneWidget);
    expect(find.text('O e-mail é único e não pode ser alterado.'),
        findsOneWidget);

    // CPF não faz mais parte desta tela.
    expect(find.text('CPF'), findsNothing);
  });

  testWidgets('o botão Salvar só habilita depois de uma alteração', (
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

    ElevatedButton botao() =>
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(botao().onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).first, 'Amanda Souza');
    await tester.pump();

    expect(botao().onPressed, isNotNull);
  });
}