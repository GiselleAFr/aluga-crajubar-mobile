import 'dart:typed_data';

import 'package:aluga_crajubar_mobile/landlord/landlord_property_details_page.dart';
import 'package:aluga_crajubar_mobile/landlord/models/landlord_property_address.dart';
import 'package:aluga_crajubar_mobile/landlord/models/landlord_property_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _photo = Uint8List.fromList([1, 2, 3]);

void main() {
  const address = LandlordPropertyAddress(
    city: 'Crato',
    neighborhood: 'Centro',
    street: 'Rua do Comércio',
    number: '123',
    complement: 'Apto 2',
  );

  Widget buildTestApp({
    Future<void> Function(LandlordPropertyDraft property)? onPropertyCreated,
  }) => MaterialApp(
    home: LandlordPropertyDetailsPage(
      address: address,
      photos: [LandlordPropertyPhoto.local(bytes: _photo)],
      mainPhotoIndex: 0,
      onPropertyCreated: onPropertyCreated,
    ),
  );

  testWidgets('shows property fields and adjusts the price by purpose', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Etapa 5 de 5'), findsOneWidget);
    expect(find.text('Nome do imóvel'), findsOneWidget);
    expect(find.text('Tipo do imóvel'), findsOneWidget);
    expect(find.text('Descrição do imóvel'), findsOneWidget);
    expect(find.text('Finalidade'), findsOneWidget);
    expect(
      find.text('Centro · Rua do Comércio, 123, Apto 2 · Crato'),
      findsOneWidget,
    );
    expect(find.text('Preço do imóvel'), findsOneWidget);
    expect(find.text('Informe o valor'), findsOneWidget);
    expect(find.textContaining('O valor será exibido'), findsOneWidget);
    expect(
      tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .last
          .controller!
          .text,
      isEmpty,
    );

    final purposeField = find.byType(
      DropdownButtonFormField<LandlordPropertyPurpose>,
    );
    await tester.ensureVisible(purposeField);
    await tester.tap(purposeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Venda').last);
    await tester.pumpAndSettle();
    expect(find.text('Preço de venda'), findsOneWidget);
    expect(
      find.byType(DropdownButtonFormField<LandlordRentalPeriod>),
      findsNothing,
    );

    await tester.tap(purposeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aluguel').last);
    await tester.pumpAndSettle();
    final periodField = find.byType(
      DropdownButtonFormField<LandlordRentalPeriod>,
    );
    await tester.tap(periodField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mensal').last);
    await tester.pumpAndSettle();
    expect(find.text('Preço mensal'), findsOneWidget);
  });

  testWidgets('validates and returns all required property fields', (
    tester,
  ) async {
    LandlordPropertyDraft? createdProperty;
    await tester.pumpWidget(
      buildTestApp(
        onPropertyCreated: (property) async {
          createdProperty = property;
        },
      ),
    );

    final continueButton = find.widgetWithText(
      FilledButton,
      'Concluir cadastro',
    );
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsNWidgets(3));
    expect(find.text('Selecione o tipo do imóvel'), findsOneWidget);
    expect(find.text('Selecione a finalidade'), findsOneWidget);

    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    fields.elementAt(0).controller!.text = 'Casa de exemplo';
    fields.elementAt(1).controller!.text =
        'Casa arejada com quintal e cozinha equipada.';
    fields.elementAt(2).controller!.text = '350,00';

    final typeField = find.byType(
      DropdownButtonFormField<LandlordPropertyType>,
    );
    await tester.ensureVisible(typeField);
    await tester.tap(typeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Casa').last);
    await tester.pumpAndSettle();

    final purposeField = find.byType(
      DropdownButtonFormField<LandlordPropertyPurpose>,
    );
    await tester.ensureVisible(purposeField);
    await tester.tap(purposeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aluguel').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsNothing);
    expect(find.text('Informe um preço maior que zero'), findsNothing);
    expect(createdProperty, isNotNull);
    expect(createdProperty!.name, 'Casa de exemplo');
    expect(
      createdProperty!.description,
      'Casa arejada com quintal e cozinha equipada.',
    );
    expect(createdProperty!.address, address);
    expect(createdProperty!.price, 350);
    expect(createdProperty!.type, LandlordPropertyType.house);
    expect(createdProperty!.purpose, LandlordPropertyPurpose.rental);
    expect(createdProperty!.rentalPeriod, LandlordRentalPeriod.daily);
    expect(createdProperty!.photos.single.bytes, _photo);
    expect(createdProperty!.mainPhotoIndex, 0);
  });
}
