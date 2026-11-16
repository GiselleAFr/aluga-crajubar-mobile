import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInput;

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
import '../../responsive_content.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService, this.initialMessage});

  final AuthService? authService;

  /// Mensagem exibida ao abrir a tela (ex.: senha alterada, sessão expirada).
  final String? initialMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  late final AuthService authService = widget.authService ?? AuthService();

  bool lembrar = true;
  bool esconderSenha = true;
  bool entrando = false;

  /// No computador e no navegador, o cursor já abre no campo de e-mail.
  /// No celular, não: o teclado só deve aparecer quando a pessoa tocar.
  bool get _focarEmailAoAbrir =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  void initState() {
    super.initState();
    final mensagem = widget.initialMessage;
    if (mensagem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  // FAZER LOGIN E ABRIR A HOME
  Future<void> fazerLogin() async {
    if (entrando) return;

    // Enter com campo vazio: leva a pessoa ao campo, sem chamar a API.
    if (emailController.text.trim().isEmpty) {
      _avisar('Informe seu e-mail.');
      emailFocus.requestFocus();
      return;
    }
    if (passwordController.text.isEmpty) {
      _avisar('Informe sua senha.');
      passwordFocus.requestFocus();
      return;
    }

    setState(() {
      entrando = true;
    });

    try {
      final user = await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        remember: lembrar,
      );

      if (!mounted) return;

      // Permite que o navegador ofereça salvar o login.
      TextInput.finishAutofillContext();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => HomePage(user: user)),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _avisar(error.message);
    } catch (_) {
      if (!mounted) return;
      _avisar('Não foi possível realizar o login. Tente novamente.');
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
          child: ResponsiveContent(
            maxWidth: 520,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AutofillGroup(
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

                  // CAMPO DE E-MAIL: Enter passa para a senha
                  LoginInput(
                    controller: emailController,
                    focusNode: emailFocus,
                    autofocus: _focarEmailAoAbrir,
                    hint: 'login/e-mail',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    onSubmitted: (_) => passwordFocus.requestFocus(),
                  ),

                  const SizedBox(height: 12),

                  // CAMPO DE SENHA: Enter entra direto
                  LoginInput(
                    controller: passwordController,
                    focusNode: passwordFocus,
                    hint: 'password',
                    icon: Icons.lock_outline,
                    obscureText: esconderSenha,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => fazerLogin(),
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
      ),
    );
  }
}