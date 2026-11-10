import 'dart:typed_data';

import 'package:aluga_crajubar_mobile/landlord/landlord_properties_page.dart';
import 'package:aluga_crajubar_mobile/landlord/landlord_property_address_page.dart';
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
  LandlordPropertyDraft makeExampleProperty({
    String name = 'Casa do Centro',
    LandlordPropertyStatus status = LandlordPropertyStatus.available,
  }) => LandlordPropertyDraft(
    name: name,
    description: 'Casa arejada com quintal.',
    address: const LandlordPropertyAddress(
      city: 'Crato',
      neighborhood: 'Centro',
      street: 'Rua do Comércio',
      number: '123',
      complement: '',
    ),
    pricePerNight: 350,
    photos: [_smallPng],
    mainPhotoIndex: 0,
    status: status,
  );

  Widget buildTestApp({
    ValueChanged<int>? onItemSelecionado,
    VoidCallback? onAdicionarImovel,
  }) => MaterialApp(
    home: LandlordPropertiesPage(
      userName: 'Amanda',
      onItemSelecionado: onItemSelecionado ?? (_) {},
      onAdicionarImovel: (_) => onAdicionarImovel?.call(),
    ),
  );

  testWidgets('renders landlord properties overview without property cards', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Olá, Amanda!'), findsOneWidget);
    expect(find.text('Buscar meus imóveis...'), findsOneWidget);
    expect(find.text('Meus imóveis'), findsOneWidget);
    expect(find.text('IMÓVEIS ATUALMENTE'), findsOneWidget);
    expect(find.text('Ordenar'), findsOneWidget);
    expect(find.byTooltip('Adicionar imóvel'), findsOneWidget);
    expect(find.text('Locador'), findsOneWidget);
    expect(find.text('Ver imóvel'), findsNothing);
  });

  testWidgets('routes bottom navigation and add-property actions', (
    tester,
  ) async {
    var selectedIndex = -1;
    var addTapped = false;

    await tester.pumpWidget(
      buildTestApp(
        onItemSelecionado: (index) => selectedIndex = index,
        onAdicionarImovel: () => addTapped = true,
      ),
    );

    await tester.tap(find.text('Buscar'));
    expect(selectedIndex, 1);

    await tester.tap(find.byTooltip('Adicionar imóvel'));
    expect(addTapped, isTrue);
  });

  testWidgets('the add-property action opens the address form', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: LandlordPropertiesPage(
          userName: 'Amanda',
          onItemSelecionado: (_) {},
          onAdicionarImovel: (_) {
            navigatorKey.currentState!.push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    LandlordPropertyAddressPage(onItemSelecionado: (_) {}),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip('Adicionar imóvel'));
    await tester.pumpAndSettle();

    expect(find.text('Endereço do imóvel'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Digite a cidade'), findsOneWidget);
  });

  testWidgets('offers sorting options', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Ordenar'));
    await tester.pumpAndSettle();

    expect(find.text('Mais recentes'), findsOneWidget);
    expect(find.text('Menor preço'), findsOneWidget);
    expect(find.text('Maior preço'), findsOneWidget);

    await tester.tap(find.text('Mais recentes'));
    await tester.pumpAndSettle();
    expect(
      find.text('A ordenação ficará disponível quando houver imóveis.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a completed listing as a local example card', (
    tester,
  ) async {
    final property = makeExampleProperty();

    await tester.pumpWidget(
      MaterialApp(
        home: LandlordPropertiesPage(
          userName: 'Amanda',
          onItemSelecionado: (_) {},
          onAdicionarImovel: (onPropertyCreated) => onPropertyCreated(property),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Adicionar imóvel'));
    await tester.pumpAndSettle();

    expect(find.text('Casa do Centro'), findsOneWidget);
    expect(find.text('Centro, Crato'), findsOneWidget);
    expect(find.textContaining('R\$ 350,00'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Editar imóvel'), findsOneWidget);
    expect(find.byTooltip('Excluir imóvel'), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byTooltip('Excluir imóvel')).dx,
      lessThan(tester.getTopLeft(find.text('Editar imóvel')).dx),
    );
  });

  testWidgets('shows the corresponding status tag on each property card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LandlordPropertiesPage(
          userName: 'Amanda',
          onItemSelecionado: (_) {},
          onAdicionarImovel: (_) {},
          properties: [
            makeExampleProperty(),
            makeExampleProperty(
              name: 'Casa alugada',
              status: LandlordPropertyStatus.rented,
            ),
            makeExampleProperty(
              name: 'Casa indisponível',
              status: LandlordPropertyStatus.unavailable,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Disponível'), findsOneWidget);
    expect(find.text('Locado'), findsOneWidget);
    expect(find.text('Indisponível'), findsOneWidget);
  });

  testWidgets('edit action opens prefilled form and updates the card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LandlordPropertiesPage(
          userName: 'Amanda',
          onItemSelecionado: (_) {},
          onAdicionarImovel: (_) {},
          properties: [makeExampleProperty()],
        ),
      ),
    );

    await tester.ensureVisible(find.text('Editar imóvel'));
    await tester.tap(find.text('Editar imóvel'));
    await tester.pumpAndSettle();

    expect(find.text('Editar fotos do imóvel'), findsOneWidget);
    expect(find.byKey(const ValueKey('property-photo-0')), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar imóvel'), findsOneWidget);
    expect(
      tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .first
          .controller!
          .text,
      'Casa do Centro',
    );

    await tester.enterText(find.byType(TextFormField).first, 'Casa atualizada');
    final saveButton = find.widgetWithText(FilledButton, 'Salvar alterações');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Casa atualizada'), findsOneWidget);
    expect(find.text('Casa do Centro'), findsNothing);
    expect(find.text('Imóvel de exemplo atualizado.'), findsOneWidget);

    await tester.ensureVisible(find.text('Editar imóvel'));
    await tester.tap(find.text('Editar imóvel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    final statusField = find.byType(
      DropdownButtonFormField<LandlordPropertyStatus>,
    );
    await tester.ensureVisible(statusField);
    await tester.tap(statusField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Locado').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(find.text('Locado'), findsOneWidget);
    expect(find.text('Disponível'), findsNothing);
  });

  testWidgets('delete action asks for confirmation and removes the card', (
    tester,
  ) async {
    List<LandlordPropertyDraft>? changedProperties;
    await tester.pumpWidget(
      MaterialApp(
        home: LandlordPropertiesPage(
          userName: 'Amanda',
          onItemSelecionado: (_) {},
          onAdicionarImovel: (_) {},
          properties: [makeExampleProperty()],
          onPropertiesChanged: (properties) => changedProperties = properties,
        ),
      ),
    );

    await tester.ensureVisible(find.byTooltip('Excluir imóvel'));
    await tester.tap(find.byTooltip('Excluir imóvel'));
    await tester.pumpAndSettle();

    expect(find.text('Excluir imóvel?'), findsOneWidget);
    expect(find.textContaining('será removido'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Casa do Centro'), findsNothing);
    expect(changedProperties, isEmpty);
    expect(
      find.text('Imóvel "Casa do Centro" removido da demonstração.'),
      findsOneWidget,
    );
  });
}
