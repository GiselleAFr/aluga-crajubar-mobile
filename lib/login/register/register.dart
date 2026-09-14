import 'package:flutter/material.dart';

import 'components/register_header.dart';
import 'components/register_text_field.dart';
import 'components/remember_me.dart';
import 'components/register_button.dart';
import 'components/return_login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool lembrarMe = true;
  bool mostrarSenha = false;
  bool mostrarConfirmarSenha = false;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();

    super.dispose();
  }

  void cadastrar() {
    if (nomeController.text.isEmpty ||
        emailController.text.isEmpty ||
        telefoneController.text.isEmpty ||
        senhaController.text.isEmpty ||
        confirmarSenhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );

      return;
    }

    if (senhaController.text != confirmarSenhaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem.'),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado com sucesso!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
            ),

            child: Column(
              children: [
                const SizedBox(height: 45),

                // HEADER
                const RegisterHeader(),

                const SizedBox(height: 80),

                // NOME
                RegisterTextField(
                  hint: 'Nome',
                  icon: Icons.person_outline,
                  controller: nomeController,
                ),

                const SizedBox(height: 12),

                // E-MAIL
                RegisterTextField(
                  hint: 'E-mail',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 12),

                // TELEFONE
                RegisterTextField(
                  hint: 'Telefone',
                  icon: Icons.phone_outlined,
                  controller: telefoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 12),

                // SENHA
                RegisterTextField(
                  hint: 'Senha',
                  icon: Icons.lock_outline,
                  controller: senhaController,
                  senha: true,
                  mostrarSenha: mostrarSenha,
                  onToggleSenha: () {
                    setState(() {
                      mostrarSenha = !mostrarSenha;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // CONFIRMAR SENHA
                RegisterTextField(
                  hint: 'Confirmar Senha',
                  icon: Icons.lock_outline,
                  controller: confirmarSenhaController,
                  senha: true,
                  mostrarSenha: mostrarConfirmarSenha,
                  onToggleSenha: () {
                    setState(() {
                      mostrarConfirmarSenha =
                          !mostrarConfirmarSenha;
                    });
                  },
                ),

                const SizedBox(height: 5),

                // LEMBRAR-ME
                RememberMe(
                  value: lembrarMe,
                  onChanged: (valor) {
                    setState(() {
                      lembrarMe = valor ?? false;
                    });
                  },
                ),

                const SizedBox(height: 40),

                // BOTÃO CADASTRAR
                RegisterButton(
                  onPressed: cadastrar,
                ),

                const SizedBox(height: 20),

                ReturnLogin(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}