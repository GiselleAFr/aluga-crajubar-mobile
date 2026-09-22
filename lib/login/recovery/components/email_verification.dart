import 'package:flutter/material.dart';

import 'code_field.dart';
import 'send_code_button.dart';

class EmailVerification extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onSendCode;

  const EmailVerification({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onSendCode,
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
          'Para sua segurança, enviaremos um código de verificação '
          'de 6 dígitos para o seu e-mail cadastrado antes de '
          'confirmar transações importantes.',
          style: TextStyle(
            fontSize: 9,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            6,
            (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                child: CodeField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],

                  nextFocusNode:
                      index < 5 ? focusNodes[index + 1] : null,

                  previousFocusNode:
                      index > 0 ? focusNodes[index - 1] : null,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        SendCodeButton(
          onPressed: onSendCode,
        ),
      ],
    );
  }
}