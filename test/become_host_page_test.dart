import 'package:aluga_crajubar_mobile/become_host/become_host_page.dart';
import 'package:aluga_crajubar_mobile/home/components/home_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp() => MaterialApp(
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF963333)),
    ),
    home: const BecomeHostPage(),
  );

  testWidgets('shows landlord navigation only when enabled', (tester) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: HomeBottomNavigation(
            indiceSelecionado: 0,
            onItemSelecionado: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Locador'), findsNothing);
    expect(find.text('Perfil'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: HomeBottomNavigation(
            indiceSelecionado: 0,
            mostrarLocador: true,
            onItemSelecionado: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Locador'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    await tester.tap(find.text('Locador'));
    expect(selectedIndex, 5);
  });

  testWidgets('selecting a birth date keeps the registration page available', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byTooltip('Selecionar data'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.text('Tornar-se Locador'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(2))
          .controller!
          .text,
      matches(RegExp(r'^\d{2}/\d{2}/\d{4}$')),
    );
  });

  testWidgets('applies CPF, birth date, and phone masks while typing', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    final cpfField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(cpfField);
    await tester.enterText(cpfField, '123456789001');
    expect(
      tester.widget<TextFormField>(cpfField).controller!.text,
      '123.456.789-00',
    );

    final birthDateField = find.byType(TextFormField).at(2);
    await tester.enterText(birthDateField, '08111990');
    expect(
      tester.widget<TextFormField>(birthDateField).controller!.text,
      '08/11/1990',
    );

    final primaryPhoneField = find.byType(TextFormField).at(4);
    await tester.ensureVisible(primaryPhoneField);
    await tester.enterText(primaryPhoneField, '888999991234');
    expect(
      tester.widget<TextFormField>(primaryPhoneField).controller!.text,
      '(88) 89999-9123',
    );
  });

  testWidgets('renders the host registration form and submit button', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Tornar-se Locador'), findsOneWidget);
    expect(
      find.text('Coloque seus imóveis para alugar e comece a ganhar!'),
      findsOneWidget,
    );
    expect(find.text('Verificado'), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(
      tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .every((field) => field.controller?.text.isEmpty ?? true),
      isTrue,
    );
    final editableFields = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(editableFields[2].readOnly, isFalse);
    expect(editableFields[3].readOnly, isFalse);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enviar Cadastro de Locador'), findsOneWidget);
    expect(find.text('Dados Bancários para Recebimento'), findsNothing);
    await tester.tap(find.text('Enviar Cadastro de Locador'));
    await tester.pumpAndSettle();

    expect(find.text('Campo obrigatório'), findsWidgets);
    expect(find.text('Selecione um banco'), findsNothing);
  });
}
