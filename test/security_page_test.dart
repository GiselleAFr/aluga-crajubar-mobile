import 'dart:convert';

import 'package:aluga_crajubar_mobile/login/login/login.dart';
import 'package:aluga_crajubar_mobile/security/security_page.dart';
import 'package:aluga_crajubar_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Armazenamento seguro em memória (o real depende de plugin nativo).
class _MemoryStorage extends FlutterSecureStorage {
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
}

class _Harness {
  _Harness(this.responder) {
    service = AuthService(
      storage: storage,
      client: MockClient((request) async {
        calls.add(request);
        return responder(request);
      }),
    );
  }

  final http.Response Function(http.Request request) responder;
  final storage = _MemoryStorage();
  final calls = <http.Request>[];
  late final AuthService service;
}

http.Response _json(int status, Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

const _msgSolicitacao =
    'Enviamos um e-mail para confirmar a alteração da sua senha.';
const _msgSucesso = 'Senha alterada com sucesso. Faça login novamente.';

Future<void> _abrirPagina(WidgetTester tester, _Harness harness) async {
  await harness.storage.write(key: 'auth_access_token', value: 'tok-123');
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(home: SecurityPage(authService: harness.service)),
  );
}

Future<void> _preencher(
  WidgetTester tester, {
  required String atual,
  required String nova,
  required String confirmacao,
}) async {
  await tester.enterText(find.byKey(const Key('senha-atual')), atual);
  await tester.enterText(find.byKey(const Key('nova-senha')), nova);
  await tester.enterText(find.byKey(const Key('confirmar-senha')), confirmacao);
}

Future<void> _tocar(WidgetTester tester, String chave) async {
  await tester.tap(find.byKey(Key(chave)));
  await tester.pumpAndSettle();
}

Future<void> _digitarCodigo(WidgetTester tester, String codigo) async {
  for (var i = 0; i < codigo.length; i++) {
    await tester.enterText(find.byKey(Key('code-box-$i')), codigo[i]);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

TextField _campo(WidgetTester tester, String chavePai) => tester.widget(
  find.descendant(
    of: find.byKey(Key(chavePai)),
    matching: find.byType(TextField),
  ),
);

bool _enviarCodigoHabilitado(WidgetTester tester) {
  final botao = tester.widget<OutlinedButton>(
    find.descendant(
      of: find.byKey(const Key('btn-enviar-codigo')),
      matching: find.byType(OutlinedButton),
    ),
  );
  return botao.onPressed != null;
}

bool _caixaFocada(WidgetTester tester, int indice) {
  final campo = tester.widget<TextField>(find.byKey(Key('code-box-$indice')));
  return campo.focusNode!.hasFocus;
}

String _textoDaCaixa(WidgetTester tester, int indice) {
  final campo = tester.widget<TextField>(find.byKey(Key('code-box-$indice')));
  return campo.controller!.text;
}

http.Response _aceitaTudo(http.Request request) {
  final path = request.url.path;
  if (path.endsWith('/auth/change-password')) {
    return _json(202, {'message': _msgSolicitacao});
  }
  if (path.endsWith('/auth/change-password/resend-code')) {
    return _json(202, {
      'message': 'Enviamos um novo código para o seu e-mail.',
    });
  }
  if (path.endsWith('/auth/change-password/verify-code')) {
    return _json(200, {'message': _msgSucesso});
  }
  return _json(404, {'message': 'Not Found'});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mostra o layout da tela', (tester) async {
    await _abrirPagina(tester, _Harness(_aceitaTudo));

    expect(find.text('Segurança e Login'), findsOneWidget);
    expect(find.text('Alterar Senha'), findsNWidgets(2)); // título + botão
    expect(find.text('Senha Atual'), findsOneWidget);
    expect(find.text('Nova Senha'), findsOneWidget);
    expect(find.text('Confirmar Nova Senha'), findsOneWidget);
    expect(find.text('Verificação por E-mail'), findsOneWidget);
    expect(find.text('Enviar Código'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      expect(find.byKey(Key('code-box-$i')), findsOneWidget);
    }
  });

  testWidgets('o olho alterna a visibilidade da senha', (tester) async {
    await _abrirPagina(tester, _Harness(_aceitaTudo));

    expect(_campo(tester, 'senha-atual').obscureText, isTrue);
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('senha-atual')),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pump();
    expect(_campo(tester, 'senha-atual').obscureText, isFalse);
  });

  testWidgets('validações locais não chamam a API', (tester) async {
    final harness = _Harness(_aceitaTudo);
    await _abrirPagina(tester, harness);

    // Campos vazios.
    await _tocar(tester, 'btn-alterar');
    expect(find.text('Informe sua senha atual.'), findsOneWidget);
    expect(find.text('Informe sua nova senha.'), findsOneWidget);
    expect(find.text('Confirme a nova senha.'), findsOneWidget);

    // Senha curta.
    await _preencher(
      tester,
      atual: 'antiga123',
      nova: '1234567',
      confirmacao: '1234567',
    );
    await _tocar(tester, 'btn-alterar');
    expect(
      find.text('A nova senha deve ter pelo menos 8 caracteres.'),
      findsOneWidget,
    );

    // Confirmação diferente.
    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'outraSenha1',
    );
    await _tocar(tester, 'btn-alterar');
    expect(
      find.text('A confirmação não confere com a nova senha.'),
      findsOneWidget,
    );

    // Nova senha igual à atual.
    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'antiga123',
      confirmacao: 'antiga123',
    );
    await _tocar(tester, 'btn-alterar');
    expect(
      find.text('A nova senha deve ser diferente da senha atual.'),
      findsOneWidget,
    );

    expect(harness.calls, isEmpty);
  });

  testWidgets('202 limpa os campos, foca a 1ª caixa e libera "Enviar Código"', (
    tester,
  ) async {
    final harness = _Harness(_aceitaTudo);
    await _abrirPagina(tester, harness);

    expect(_enviarCodigoHabilitado(tester), isFalse);

    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');

    final chamada = harness.calls.single;
    expect(chamada.method, 'POST');
    expect(chamada.url.path, endsWith('/api/auth/change-password'));
    expect(chamada.headers['Authorization'], 'Bearer tok-123');
    expect(chamada.headers['Accept'], 'application/json');
    expect(jsonDecode(chamada.body), {
      'current_password': 'antiga123',
      'password': 'novaSenha1',
      'password_confirmation': 'novaSenha1',
    });

    expect(find.text(_msgSolicitacao), findsOneWidget);
    expect(_campo(tester, 'senha-atual').controller!.text, isEmpty);
    expect(_campo(tester, 'nova-senha').controller!.text, isEmpty);
    expect(_campo(tester, 'confirmar-senha').controller!.text, isEmpty);
    expect(_caixaFocada(tester, 0), isTrue);
    expect(_enviarCodigoHabilitado(tester), isTrue);
  });

  testWidgets('422 em current_password aparece no campo Senha Atual', (
    tester,
  ) async {
    final harness = _Harness(
      (_) => _json(422, {
        'message': 'A senha atual está incorreta.',
        'errors': {
          'current_password': ['A senha atual está incorreta.'],
        },
      }),
    );
    await _abrirPagina(tester, harness);

    await _preencher(
      tester,
      atual: 'errada123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');

    expect(find.text('A senha atual está incorreta.'), findsOneWidget);
    expect(_enviarCodigoHabilitado(tester), isFalse);
  });

  testWidgets('422 em password aparece no campo Nova Senha', (tester) async {
    final harness = _Harness(
      (_) => _json(422, {
        'message': 'Erro de validação.',
        'errors': {
          'password': ['A nova senha deve ser diferente da senha atual.'],
        },
      }),
    );
    await _abrirPagina(tester, harness);

    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');

    expect(
      find.text('A nova senha deve ser diferente da senha atual.'),
      findsOneWidget,
    );
  });

  testWidgets('429 mostra mensagem clara em português', (tester) async {
    final harness = _Harness(
      (_) => _json(429, {'message': 'Too Many Attempts.'}),
    );
    await _abrirPagina(tester, harness);

    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');

    expect(
      find.text('Muitas tentativas. Aguarde um minuto e tente novamente.'),
      findsOneWidget,
    );
    expect(find.text('Too Many Attempts.'), findsNothing);
  });

  testWidgets('falha de rede mostra mensagem clara', (tester) async {
    final harness = _Harness((_) => throw http.ClientException('sem rede'));
    await _abrirPagina(tester, harness);

    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');

    expect(
      find.textContaining('Não foi possível conectar à API'),
      findsOneWidget,
    );
  });

  testWidgets('401 ao alterar a senha trata a sessão expirada', (tester) async {
    final harness = _Harness(
      (_) => _json(401, {'message': 'Unauthenticated.'}),
    );
    await _abrirPagina(tester, harness);

    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Sua sessão expirou. Entre novamente.'), findsOneWidget);
    expect(await harness.service.accessToken, isNull);
  });

  testWidgets('o 6º dígito envia o código; 200 apaga o token e vai ao login', (
    tester,
  ) async {
    final harness = _Harness(_aceitaTudo);
    await _abrirPagina(tester, harness);

    await _digitarCodigo(tester, '483912');

    final chamada = harness.calls.single;
    expect(chamada.method, 'POST');
    expect(chamada.url.path, endsWith('/api/auth/change-password/verify-code'));
    expect(chamada.headers['Authorization'], 'Bearer tok-123');
    expect(jsonDecode(chamada.body), {'code': '483912'});

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SecurityPage), findsNothing);
    expect(find.text(_msgSucesso), findsOneWidget);
    expect(await harness.service.accessToken, isNull);
  });

  testWidgets('colar um código de 6 dígitos preenche e envia', (tester) async {
    final harness = _Harness(_aceitaTudo);
    await _abrirPagina(tester, harness);

    await tester.enterText(find.byKey(const Key('code-box-0')), '483912');
    await tester.pumpAndSettle();

    expect(jsonDecode(harness.calls.single.body), {'code': '483912'});
  });

  testWidgets('as caixas aceitam somente dígitos', (tester) async {
    final harness = _Harness(_aceitaTudo);
    await _abrirPagina(tester, harness);

    await tester.enterText(find.byKey(const Key('code-box-0')), 'a');
    await tester.pump();

    expect(_textoDaCaixa(tester, 0), isEmpty);
    expect(harness.calls, isEmpty);
  });

  testWidgets('422 do código limpa as caixas e mostra o erro', (tester) async {
    final harness = _Harness(
      (_) => _json(422, {'message': 'O código é inválido ou expirou.'}),
    );
    await _abrirPagina(tester, harness);

    await _digitarCodigo(tester, '111111');

    expect(find.text('O código é inválido ou expirou.'), findsOneWidget);
    expect(find.byType(SecurityPage), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      expect(_textoDaCaixa(tester, i), isEmpty);
    }
    expect(_caixaFocada(tester, 0), isTrue);
  });

  testWidgets('401 ao verificar o código trata a sessão expirada', (
    tester,
  ) async {
    final harness = _Harness(
      (_) => _json(401, {'message': 'Unauthenticated.'}),
    );
    await _abrirPagina(tester, harness);

    await _digitarCodigo(tester, '483912');

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Sua sessão expirou. Entre novamente.'), findsOneWidget);
    expect(await harness.service.accessToken, isNull);
  });

  testWidgets('429 ao verificar o código mostra mensagem e limpa as caixas', (
    tester,
  ) async {
    final harness = _Harness(
      (_) => _json(429, {'message': 'Too Many Attempts.'}),
    );
    await _abrirPagina(tester, harness);

    await _digitarCodigo(tester, '483912');

    expect(
      find.text('Muitas tentativas. Aguarde um minuto e tente novamente.'),
      findsOneWidget,
    );
    expect(_textoDaCaixa(tester, 0), isEmpty);
  });

  testWidgets('"Enviar Código" chama resend-code', (tester) async {
    final harness = _Harness(_aceitaTudo);
    await _abrirPagina(tester, harness);

    await _preencher(
      tester,
      atual: 'antiga123',
      nova: 'novaSenha1',
      confirmacao: 'novaSenha1',
    );
    await _tocar(tester, 'btn-alterar');
    harness.calls.clear();

    await _tocar(tester, 'btn-enviar-codigo');

    final chamada = harness.calls.single;
    expect(chamada.method, 'POST');
    expect(chamada.url.path, endsWith('/api/auth/change-password/resend-code'));
    expect(chamada.headers['Authorization'], 'Bearer tok-123');
    expect(find.byType(SecurityPage), findsOneWidget);
  });
}
