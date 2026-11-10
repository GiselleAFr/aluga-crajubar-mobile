import 'dart:typed_data';

import 'package:aluga_crajubar_mobile/landlord/landlord_property_photos_page.dart';
import 'package:aluga_crajubar_mobile/landlord/landlord_property_details_page.dart';
import 'package:aluga_crajubar_mobile/landlord/models/landlord_property_address.dart';
import 'package:aluga_crajubar_mobile/landlord/models/landlord_property_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _smallPng = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0B,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0xA5,
  0xF6,
  0x45,
  0x40,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  Widget buildTestApp({
    Future<List<Uint8List>?> Function(int remaining)? onPickFiles,
    ValueChanged<LandlordPropertyDraft>? onPropertyCreated,
    LandlordPropertyDraft? initialProperty,
  }) => MaterialApp(
    home: LandlordPropertyPhotosPage(
      address: const LandlordPropertyAddress(
        city: 'Crato',
        neighborhood: 'Centro',
        street: 'Rua do Comércio',
        number: '123',
        complement: '',
      ),
      onPickFiles: onPickFiles,
      onPropertyCreated: onPropertyCreated,
      initialProperty: initialProperty,
    ),
  );

  testWidgets('renders the empty photo step and limit', (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Etapa 4 de 5'), findsOneWidget);
    expect(find.text('Fotos do imóvel'), findsOneWidget);
    expect(find.text('0 de 10'), findsOneWidget);
    expect(find.text('Adicionar imagens'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('adds photos and allows selecting a main photo and removing', (
    tester,
  ) async {
    final requestedLimits = <int>[];
    await tester.pumpWidget(
      buildTestApp(
        onPickFiles: (remaining) async {
          requestedLimits.add(remaining);
          return [_smallPng, _smallPng];
        },
      ),
    );

    final addPhotosButton = find.ancestor(
      of: find.text('Adicionar imagens'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(addPhotosButton);
    await tester.tap(addPhotosButton.first);
    await tester.pumpAndSettle();

    expect(requestedLimits, [10]);
    expect(find.text('2 de 10'), findsOneWidget);
    expect(find.text('★  Foto principal'), findsOneWidget);
    expect(find.text('Definir como principal'), findsOneWidget);
    expect(find.byKey(const ValueKey('main-photo-0')), findsOneWidget);

    final setAsMain = find.ancestor(
      of: find.text('Definir como principal'),
      matching: find.byType(TextButton),
    );
    await tester.ensureVisible(setAsMain);
    await tester.tap(setAsMain);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('main-photo-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('main-photo-0')), findsNothing);

    final firstRemove = find.descendant(
      of: find.byKey(const ValueKey('property-photo-0')),
      matching: find.byTooltip('Remover foto'),
    );
    await tester.ensureVisible(firstRemove);
    await tester.tap(firstRemove);
    await tester.pumpAndSettle();
    expect(find.text('1 de 10'), findsOneWidget);
  });

  testWidgets('requires at least one photo before continuing', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Adicione ao menos uma foto para continuar.'),
      findsOneWidget,
    );
  });

  testWidgets('continues to details and carries the entered address', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(onPickFiles: (_) async => [_smallPng]),
    );

    await tester.tap(find.text('Adicionar imagens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.byType(LandlordPropertyDetailsPage), findsOneWidget);
    expect(find.text('Centro · Rua do Comércio, 123 · Crato'), findsOneWidget);
    expect(find.text('Etapa 5 de 5'), findsOneWidget);
  });

  testWidgets('carries photos and form details to the completion callback', (
    tester,
  ) async {
    LandlordPropertyDraft? createdProperty;
    await tester.pumpWidget(
      buildTestApp(
        onPickFiles: (_) async => [_smallPng],
        onPropertyCreated: (property) => createdProperty = property,
      ),
    );

    await tester.tap(find.text('Adicionar imagens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    fields.elementAt(0).controller!.text = 'Casa do Centro';
    fields.elementAt(1).controller!.text = 'Casa com quintal.';
    fields.elementAt(2).controller!.text = '350,00';

    final continueButton = find.widgetWithText(
      FilledButton,
      'Concluir cadastro',
    );
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(createdProperty, isNotNull);
    expect(createdProperty!.name, 'Casa do Centro');
    expect(createdProperty!.photos, hasLength(1));
    expect(createdProperty!.mainPhotoIndex, 0);
    expect(createdProperty!.address.city, 'Crato');
    expect(createdProperty!.pricePerNight, 350);
  });

  testWidgets('editing keeps existing photos and saves gallery changes', (
    tester,
  ) async {
    final initialProperty = LandlordPropertyDraft(
      name: 'Casa do Centro',
      description: 'Casa com quintal.',
      address: const LandlordPropertyAddress(
        city: 'Crato',
        neighborhood: 'Centro',
        street: 'Rua do Comércio',
        number: '123',
        complement: '',
      ),
      pricePerNight: 350,
      photos: [_smallPng, _smallPng],
      mainPhotoIndex: 0,
    );
    LandlordPropertyDraft? updatedProperty;

    await tester.pumpWidget(
      buildTestApp(
        initialProperty: initialProperty,
        onPickFiles: (_) async => [_smallPng],
        onPropertyCreated: (property) => updatedProperty = property,
      ),
    );

    expect(find.text('Editar fotos do imóvel'), findsOneWidget);
    expect(find.text('2 de 10'), findsOneWidget);
    expect(find.byKey(const ValueKey('main-photo-0')), findsOneWidget);

    final makeSecondMain = find.ancestor(
      of: find.text('Definir como principal'),
      matching: find.byType(TextButton),
    );
    await tester.ensureVisible(makeSecondMain);
    await tester.tap(makeSecondMain);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('main-photo-1')), findsOneWidget);

    final addPhotosButton = find.ancestor(
      of: find.text('Adicionar imagens'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(addPhotosButton);
    await tester.tap(addPhotosButton.first);
    await tester.pumpAndSettle();
    expect(find.text('3 de 10'), findsOneWidget);

    final removeFirstPhoto = find.descendant(
      of: find.byKey(const ValueKey('property-photo-0')),
      matching: find.byTooltip('Remover foto'),
    );
    await tester.ensureVisible(removeFirstPhoto);
    await tester.tap(removeFirstPhoto);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('main-photo-0')), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar imóvel'), findsOneWidget);
    final saveButton = find.widgetWithText(FilledButton, 'Salvar alterações');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(updatedProperty, isNotNull);
    expect(updatedProperty!.photos, hasLength(2));
    expect(updatedProperty!.mainPhotoIndex, 0);
    expect(updatedProperty!.name, 'Casa do Centro');
  });
}
