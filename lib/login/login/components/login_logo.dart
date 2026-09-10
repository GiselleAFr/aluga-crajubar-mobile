import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFDCEFF3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',//logoo
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Entrar',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFA83232),
          ),
        ),
      ],
    );
  }
}