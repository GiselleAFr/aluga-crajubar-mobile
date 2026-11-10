import 'package:aluga_crajubar_mobile/landlord/landlord_property_address_page.dart';
import 'package:aluga_crajubar_mobile/landlord/landlord_property_photos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp() =>
      MaterialApp(home: LandlordPropertyAddressPage(onItemSelecionado: (_) {}));

  testWidgets('shows all address fields and landlord navigation', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Cadastre seu imóvel'), findsNWidgets(2));
    expect(find.text('Endereço do imóvel'), findsOneWidget);
    expect(find.text('Cidade'), findsOneWidget);
    expect(find.text('Bairro'), findsOneWidget);
    expect(find.text('Rua'), findsOneWidget);
    expect(find.text('Número da casa'), findsOneWidget);
    expect(find.text('Complemento'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Locador'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('requires address fields before opening photos', (tester) async {
    await tester.pumpWidget(buildTestApp());
    final continueButton = find.widgetWithText(FilledButton, 'Continuar');
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsNWidgets(4));

    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(0));
    await tester.enterText(fields.at(0), 'Crato');
    await tester.ensureVisible(fields.at(1));
    await tester.enterText(fields.at(1), 'Centro');
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), 'Rua do Comércio');
    await tester.ensureVisible(fields.at(3));
    await tester.enterText(fields.at(3), '123');
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsNothing);
    expect(find.byType(LandlordPropertyPhotosPage), findsOneWidget);
    expect(find.text('Fotos do imóvel'), findsOneWidget);
  });
}
