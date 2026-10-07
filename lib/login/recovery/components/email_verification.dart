import 'package:flutter/material.dart';

import 'send_code_button.dart';

class EmailVerification extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSendCode;
  final bool isLoading;

  const EmailVerification({
    super.key,
    required this.emailController,
    required this.onSendCode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),

        const SizedBox(height: 15),

        const Text(
          'Verificação por e-mail',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA83232),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Informe seu e-mail cadastrado. Enviaremos um link seguro '
          'para redefinir sua senha.',
          style: TextStyle(fontSize: 9, height: 1.4),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 12),

        SendCodeButton(onPressed: onSendCode, isLoading: isLoading),
      ],
    );
  }
}
