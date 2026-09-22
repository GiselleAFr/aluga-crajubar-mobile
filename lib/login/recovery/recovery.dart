import 'package:flutter/material.dart';

import 'components/recovery_header.dart';
import 'components/password_field.dart';
import 'components/change_password_button.dart';
import 'components/email_verification.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({
    super.key,
  });

  @override
  State<RecoveryPage> createState() =>
      _RecoveryPageState();
}

class _RecoveryPageState
  extends State<RecoveryPage> {

  // ==========================================
  // CAMPOS
  // ==========================================

  final novaSenhaController =
      TextEditingController();

  final confirmarSenhaController =
      TextEditingController();


  // ==========================================
  // CÓDIGO
  // ==========================================

  final codigoControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final codigoFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );


  // ==========================================
  // MOSTRAR / ESCONDER SENHAS
  // ==========================================

  bool esconderSenhaAtual = true;

  bool esconderNovaSenha = true;

  bool esconderConfirmarSenha = true;


  // ==========================================
  // BOTÃO ALTERAR SENHA
  // ==========================================

  void alterarSenha() {
    print('Botão Alterar Senha pressionado');

  

    print(
      'Nova senha: ${novaSenhaController.text}',
    );

    print(
      'Confirmar senha: ${confirmarSenhaController.text}',
    );
  }


  // ==========================================
  // BOTÃO ENVIAR CÓDIGO
  // ==========================================

  void enviarCodigo() {
    String codigo = '';

    for (final controller in codigoControllers) {
      codigo += controller.text;
    }

    print('Código: $codigo');
  }


  // ==========================================
  // VOLTAR
  // ==========================================

  void voltar() {
    Navigator.pop(context);
  }


  // ==========================================
  // LIMPAR MEMÓRIA
  // ==========================================

  @override
  void dispose() {
    
    novaSenhaController.dispose();

    confirmarSenhaController.dispose();

    for (final controller in codigoControllers) {
      controller.dispose();
    }

    for (final focusNode in codigoFocusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }


  // ==========================================
  // TELA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ================================
            // CABEÇALHO
            // ================================

            RecoveryHeader(
              onBack: voltar,
            ),

            const Divider(
              height: 1,
            ),


            // ================================
            // CONTEÚDO
            // ================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ==========================
                    // TÍTULO
                    // ==========================

                    const Text(
                      'Alterar Senha',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA83232),
                      ),
                    ),

                    const SizedBox(height: 10),


                    // ==========================
                    // NOVA SENHA
                    // ==========================

                    PasswordField(
                      label: 'Nova Senha',

                      controller:
                          novaSenhaController,

                      obscureText:
                          esconderNovaSenha,

                      onVisibilityPressed: () {
                        setState(() {
                          esconderNovaSenha =
                              !esconderNovaSenha;
                        });
                      },
                    ),

                    const SizedBox(height: 10),


                    // ==========================
                    // CONFIRMAR SENHA
                    // ==========================

                    PasswordField(
                      label: 'Confirmar Nova Senha',

                      controller:
                          confirmarSenhaController,

                      obscureText:
                          esconderConfirmarSenha,

                      onVisibilityPressed: () {
                        setState(() {
                          esconderConfirmarSenha =
                              !esconderConfirmarSenha;
                        });
                      },
                    ),

                    const SizedBox(height: 12),


                    // ==========================
                    // ALTERAR SENHA
                    // ==========================

                    ChangePasswordButton(
                      onPressed: alterarSenha,
                    ),

                    const SizedBox(height: 10),


                    // ==========================
                    // VERIFICAÇÃO
                    // ==========================

                    EmailVerification(
                      controllers:
                          codigoControllers,

                      focusNodes:
                          codigoFocusNodes,

                      onSendCode:
                          enviarCodigo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}