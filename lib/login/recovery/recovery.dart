import 'package:flutter/material.dart';

import 'components/recovery_header.dart';
import 'components/password_field.dart';
import 'components/change_password_button.dart';
import 'components/email_verification.dart';
import '../../services/auth_service.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key, this.resetEmail, this.resetToken});

  final String? resetEmail;
  final String? resetToken;

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  // ==========================================
  // CAMPOS
  // ==========================================

  final novaSenhaController = TextEditingController();

  final confirmarSenhaController = TextEditingController();
  final emailController = TextEditingController();
  final authService = AuthService();
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.resetEmail ?? '';
  }

  // ==========================================
  // MOSTRAR / ESCONDER SENHAS
  // ==========================================

  bool esconderSenhaAtual = true;

  bool esconderNovaSenha = true;

  bool esconderConfirmarSenha = true;

  // ==========================================
  // BOTÃO ALTERAR SENHA
  // ==========================================

  Future<void> alterarSenha() async {
    if (novaSenhaController.text.length < 8) {
      _mostrarMensagem('A senha deve ter pelo menos 8 caracteres.');
      return;
    }
    if (novaSenhaController.text != confirmarSenhaController.text) {
      _mostrarMensagem('As senhas não coincidem.');
      return;
    }

    setState(() => enviando = true);
    try {
      final message = await authService.resetPassword(
        email: emailController.text,
        token: widget.resetToken!,
        password: novaSenhaController.text,
        passwordConfirmation: confirmarSenhaController.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } on AuthException catch (error) {
      _mostrarMensagem(error.message);
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  // ==========================================
  // BOTÃO ENVIAR CÓDIGO
  // ==========================================

  Future<void> enviarCodigo() async {
    if (!emailController.text.contains('@')) {
      _mostrarMensagem('Informe um e-mail válido.');
      return;
    }

    setState(() => enviando = true);
    try {
      final message = await authService.requestPasswordReset(
        email: emailController.text,
      );
      _mostrarMensagem(message);
    } on AuthException catch (error) {
      _mostrarMensagem(error.message);
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  void _mostrarMensagem(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

    emailController.dispose();

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

            RecoveryHeader(onBack: voltar),

            const Divider(height: 1),

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
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==========================
                    // TÍTULO
                    // ==========================

                    Text(
                      widget.resetToken == null
                          ? 'Recuperar Senha'
                          : 'Alterar Senha',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA83232),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ==========================
                    if (widget.resetToken != null) ...[
                      // NOVA SENHA
                      // ==========================

                      PasswordField(
                        label: 'Nova Senha',

                        controller: novaSenhaController,

                        obscureText: esconderNovaSenha,

                        onVisibilityPressed: () {
                          setState(() {
                            esconderNovaSenha = !esconderNovaSenha;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // ==========================
                      // CONFIRMAR SENHA
                      // ==========================
                      PasswordField(
                        label: 'Confirmar Nova Senha',

                        controller: confirmarSenhaController,

                        obscureText: esconderConfirmarSenha,

                        onVisibilityPressed: () {
                          setState(() {
                            esconderConfirmarSenha = !esconderConfirmarSenha;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // ==========================
                      // ALTERAR SENHA
                      // ==========================
                      ChangePasswordButton(
                        onPressed: alterarSenha,
                        isLoading: enviando,
                      ),

                      const SizedBox(height: 10),
                    ],

                    // ==========================
                    // VERIFICAÇÃO
                    // ==========================
                    if (widget.resetToken == null)
                      EmailVerification(
                        emailController: emailController,
                        onSendCode: enviarCodigo,
                        isLoading: enviando,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Redefinindo a senha de ${emailController.text}',
                        ),
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
