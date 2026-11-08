import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'security_colors.dart';

/// Seis caixas de um dígito para o código de verificação.
///
/// - aceita somente dígitos e abre o teclado numérico;
/// - avança ao digitar e volta ao apagar;
/// - aceita colar o código inteiro;
/// - chama [onCompleted] assim que a sexta caixa é preenchida.
///
/// Use uma `GlobalKey<CodeBoxesState>` para limpar as caixas ou focar a
/// primeira.
class CodeBoxes extends StatefulWidget {
  const CodeBoxes({super.key, required this.onCompleted, this.enabled = true});

  final ValueChanged<String> onCompleted;
  final bool enabled;

  @override
  State<CodeBoxes> createState() => CodeBoxesState();
}

class CodeBoxesState extends State<CodeBoxes> {
  static const _tamanho = 6;
  static const _espaco = 8.0;
  static const _recuo = 16.0;
  static const _larguraMaxima = 42.0;

  final List<TextEditingController> _controllers = List.generate(
    _tamanho,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _tamanho,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _tamanho; i++) {
      // Ao focar, seleciona o dígito atual: o próximo digitado o substitui.
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus) {
          return;
        }
        final controller = _controllers[i];
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Esvazia as seis caixas.
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
  }

  /// Coloca o foco (e o teclado) na primeira caixa.
  void focusFirst() => _focusNodes.first.requestFocus();

  String get _codigo => _controllers.map((c) => c.text).join();

  void _definir(int indice, String digito) {
    _controllers[indice].value = TextEditingValue(
      text: digito,
      selection: TextSelection.collapsed(offset: digito.length),
    );
  }

  void _onChanged(int indice, String valor) {
    final digitos = valor.replaceAll(RegExp(r'\D'), '');

    if (digitos.isEmpty) {
      _definir(indice, '');
      if (indice > 0) {
        _focusNodes[indice - 1].requestFocus();
      }
      return;
    }

    var proximo = indice + 1;
    if (digitos.length <= 2) {
      // Digitou um dígito (se a caixa já tinha um, vale o último digitado).
      _definir(indice, digitos[digitos.length - 1]);
    } else {
      // Colou vários dígitos: um código completo começa na primeira caixa.
      final inicio = digitos.length >= _tamanho ? 0 : indice;
      final quantidade = math.min(digitos.length, _tamanho - inicio);
      for (var i = 0; i < quantidade; i++) {
        _definir(inicio + i, digitos[i]);
      }
      proximo = inicio + quantidade;
    }

    if (_codigo.length == _tamanho) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(_codigo);
      return;
    }

    if (proximo < _tamanho) {
      _focusNodes[proximo].requestFocus();
    }
  }

  KeyEventResult _onKey(int indice, KeyEvent evento) {
    // Backspace numa caixa vazia: apaga e volta para a anterior.
    if (evento is KeyDownEvent &&
        evento.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[indice].text.isEmpty &&
        indice > 0) {
      _controllers[indice - 1].clear();
      _focusNodes[indice - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  OutlineInputBorder _borda(Color cor) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: cor),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final disponivel = constraints.maxWidth - _recuo - _espaco * 5;
        final largura = math.min(_larguraMaxima, disponivel / _tamanho);

        return Padding(
          padding: const EdgeInsets.only(left: _recuo),
          child: Row(
            children: [
              for (var i = 0; i < _tamanho; i++) ...[
                Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onKeyEvent: (_, evento) => _onKey(i, evento),
                  child: SizedBox(
                    width: largura,
                    height: 50,
                    child: TextField(
                      key: Key('code-box-$i'),
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      enabled: widget.enabled,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SecurityColors.vinho,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: _borda(SecurityColors.borda),
                        enabledBorder: _borda(SecurityColors.borda),
                        disabledBorder: _borda(SecurityColors.borda),
                        focusedBorder: _borda(SecurityColors.vinho),
                      ),
                      onChanged: (valor) => _onChanged(i, valor),
                    ),
                  ),
                ),
                if (i < _tamanho - 1) const SizedBox(width: _espaco),
              ],
            ],
          ),
        );
      },
    );
  }
}
