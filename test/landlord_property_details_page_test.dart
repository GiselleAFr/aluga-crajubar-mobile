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
    ValueChanged<LandlordPropertyDraft>? onPropertyCreated,
  }) => MaterialApp(
    home: LandlordPropertyDetailsPage(
      address: address,
      photos: [_photo],
      mainPhotoIndex: 0,
      onPropertyCreated: onPropertyCreated,
    ),
  );

  testWidgets('shows description, location, and a demonstration price field', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Etapa 5 de 5'), findsOneWidget);
    expect(find.text('Nome do imóvel'), findsOneWidget);
    expect(find.text('Descrição do imóvel'), findsOneWidget);
    expect(
      find.text('Centro · Rua do Comércio, 123, Apto 2 · Crato'),
      findsOneWidget,
    );
    expect(find.text('Preço por noite'), findsOneWidget);
    expect(find.text('Ex.: 350,00'), findsOneWidget);
    expect(
      find.textContaining('Valor de exemplo para demonstração'),
      findsOneWidget,
    );
    expect(
      tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .last
          .controller!
          .text,
      isEmpty,
    );
  });

  testWidgets('validates details and price without publishing the listing', (
    tester,
  ) async {
    LandlordPropertyDraft? createdProperty;
    await tester.pumpWidget(
      buildTestApp(onPropertyCreated: (property) => createdProperty = property),
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

    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    fields.elementAt(0).controller!.text = 'Casa de exemplo';
    fields.elementAt(1).controller!.text =
        'Casa arejada com quintal e cozinha equipada.';
    fields.elementAt(2).controller!.text = '350,00';
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
    expect(createdProperty!.pricePerNight, 350);
    expect(createdProperty!.photos, [_photo]);
    expect(createdProperty!.mainPhotoIndex, 0);
  });
}
