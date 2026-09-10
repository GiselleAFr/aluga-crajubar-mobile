import 'package:flutter/material.dart';

import 'components/login_logo.dart';
import 'components/login_input.dart';
import 'components/remember_me.dart';
import 'components/login_button.dart';
import 'components/register_button.dart';
import 'components/forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool lembrar = true;
  bool esconderSenha = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void fazerLogin() {
    String email = emailController.text;
    String senha = passwordController.text;

    print('Email: $email');
    print('Senha: $senha');
  }

  void abrirCadastro() {
    print('Abrir tela de cadastro');
  }

  void recuperarSenha() {
    print('Recuperar senha');
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

                // LOGO + TÍTULO
                const LoginLogo(),

                const SizedBox(height: 80),

                // EMAIL
                LoginInput(
                  controller: emailController,
                  hint: 'login/e-mail',
                  icon: Icons.mail_outline,
                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(height: 12),

                // SENHA
                LoginInput(
                  controller: passwordController,
                  hint: 'password',
                  icon: Icons.lock_outline,
                  obscureText: esconderSenha,

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        esconderSenha =
                            !esconderSenha;
                      });
                    },

                    icon: Icon(
                      esconderSenha
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,

                      size: 17,

                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                // LEMBRAR
                RememberMe(
                  value: lembrar,

                  onChanged: (valor) {
                    setState(() {
                      lembrar = valor ?? false;
                    });
                  },
                ),

                const SizedBox(height: 52),

                // LOGIN
                LoginButton(
                  onPressed: fazerLogin,
                ),

                const SizedBox(height: 10),

                // CADASTRO
                RegisterButton(
                  onPressed: abrirCadastro,
                ),

                const SizedBox(height: 13),

                // ESQUECEU SENHA
                ForgotPassword(
                  onPressed: recuperarSenha,
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