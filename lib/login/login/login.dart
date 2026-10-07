import 'package:flutter/material.dart';

import 'components/login_logo.dart';
import 'components/login_input.dart';
import 'components/remember_me.dart';
import 'components/login_button.dart';
import 'components/register_button.dart';
import 'components/forgot_password.dart';
import '../register/register.dart';
import '../recovery/recovery.dart';
import '../session_page.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool lembrar = true;
  bool esconderSenha = true;
  bool entrando = false;
  final authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> fazerLogin() async {
    if (entrando) return;
    setState(() => entrando = true);
    try {
      final user = await authService.login(
        email: emailController.text,
        password: passwordController.text,
        remember: lembrar,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => SessionPage(user: user)),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => entrando = false);
    }
  }

  // ABRIR TELA DE CADASTRO
  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void recuperarSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecoveryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),

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
                  keyboardType: TextInputType.emailAddress,
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
                        esconderSenha = !esconderSenha;
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
                  onPressed: entrando ? null : fazerLogin,
                  isLoading: entrando,
                ),

                const SizedBox(height: 10),

                // CADASTRO
                RegisterButton(onPressed: abrirCadastro),

                const SizedBox(height: 13),

                // ESQUECEU SENHA
                ForgotPassword(onPressed: recuperarSenha),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
