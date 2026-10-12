import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'components/login_logo.dart';
import 'components/login_input.dart';
import 'components/remember_me.dart';
import 'components/login_button.dart';
import 'components/register_button.dart';
import 'components/forgot_password.dart';

import '../register/register.dart';
import '../recovery/recovery.dart';

import '../../home/home_page.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool lembrar = true;
  bool esconderSenha = true;
  bool entrando = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // FAZER LOGIN E ABRIR A HOME
  Future<void> fazerLogin() async {
    if (entrando) return;

    setState(() {
      entrando = true;
    });

    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        remember: lembrar,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível realizar o login. Tente novamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          entrando = false;
        });
      }
    }
  }

  // ABRIR TELA DE CADASTRO
  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
    );
  }

  // ABRIR TELA DE RECUPERAÇÃO DE SENHA
  void recuperarSenha() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const RecoveryPage()),
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

                // LOGO E TÍTULO
                const LoginLogo(),

                const SizedBox(height: 28),

                if (kDebugMode) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Acesso temporário para demonstração',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text('E-mail: ${AuthService.temporaryLoginEmail}'),
                        Text('Senha: ${AuthService.temporaryLoginPassword}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ] else
                  const SizedBox(height: 52),

                // CAMPO DE E-MAIL
                LoginInput(
                  controller: emailController,
                  hint: 'login/e-mail',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 12),

                // CAMPO DE SENHA
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

                // LEMBRAR LOGIN
                RememberMe(
                  value: lembrar,
                  onChanged: (valor) {
                    setState(() {
                      lembrar = valor ?? false;
                    });
                  },
                ),

                const SizedBox(height: 52),

                // BOTÃO DE LOGIN
                LoginButton(
                  onPressed: entrando ? null : fazerLogin,
                  isLoading: entrando,
                ),

                const SizedBox(height: 10),

                // BOTÃO DE CADASTRO
                RegisterButton(onPressed: abrirCadastro),

                const SizedBox(height: 13),

                // ESQUECI MINHA SENHA
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
