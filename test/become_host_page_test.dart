import 'dart:async';
import 'dart:typed_data';

import 'package:aluga_crajubar_mobile/become_host/become_host_page.dart';
import 'package:aluga_crajubar_mobile/become_host/models/become_host_form.dart';
import 'package:aluga_crajubar_mobile/home/components/home_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp({
    Future<void> Function(BecomeHostForm form)? onSubmit,
    Future<HostDocumentPhoto?> Function(bool isFront)? documentPicker,
  }) => MaterialApp(
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
    home: BecomeHostPage(onSubmit: onSubmit, documentPicker: documentPicker),
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

  testWidgets('submits validated form data asynchronously', (tester) async {
    final submission = Completer<void>();
    BecomeHostForm? submittedForm;
    Future<HostDocumentPhoto?> pickDocument(bool isFront) async =>
        HostDocumentPhoto(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: isFront ? 'frente.png' : 'verso.jpeg',
        );

    await tester.pumpWidget(
      buildTestApp(
        onSubmit: (form) {
          submittedForm = form;
          return submission.future;
        },
        documentPicker: pickDocument,
      ),
    );

    final values = [
      'Ana Maria Silva',
      '52998224725',
      '08111990',
      'ana@example.com',
      '88999991234',
      '8833334444',
      '',
    ];
    for (var index = 0; index < values.length; index++) {
      final field = find.byType(TextFormField).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[index]);
    }

    final frontUpload = find.text('Enviar foto do documento (frente)');
    await tester.ensureVisible(frontUpload);
    await tester.tap(frontUpload);
    await tester.pumpAndSettle();
    final backUpload = find.text('Enviar foto do documento (verso)');
    await tester.tap(backUpload);
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(
      FilledButton,
      'Enviar Cadastro de Locador',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(submittedForm?.fullName, 'Ana Maria Silva');
    expect(submittedForm?.cpf, '529.982.247-25');
    expect(submittedForm?.birthDate, DateTime(1990, 11, 8));
    expect(submittedForm?.documentType, HostDocumentType.rg);
    expect(submittedForm?.email, 'ana@example.com');
    expect(submittedForm?.primaryPhone, '(88) 99999-1234');
    expect(submittedForm?.secondaryPhone, '(88) 3333-4444');
    expect(submittedForm?.documentFront.fileName, 'frente.png');
    expect(submittedForm?.documentBack.fileName, 'verso.jpeg');
    expect(submittedForm?.documentFront.bytes, [1, 2, 3]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    submission.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('requires both document sides before submitting', (tester) async {
    await tester.pumpWidget(buildTestApp(onSubmit: (_) async {}));

    final values = [
      'Ana Maria Silva',
      '52998224725',
      '08111990',
      'ana@example.com',
      '88999991234',
      '8833334444',
      '',
    ];
    for (var index = 0; index < values.length; index++) {
      final field = find.byType(TextFormField).at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[index]);
    }

    final submitButton = find.widgetWithText(
      FilledButton,
      'Enviar Cadastro de Locador',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Envie a frente do documento.'), findsOneWidget);
    expect(find.text('Envie o verso do documento.'), findsOneWidget);
  });
}
