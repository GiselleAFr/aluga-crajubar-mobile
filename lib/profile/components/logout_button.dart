import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 34,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF963333),
        side: const BorderSide(color: Color(0xFF963333), width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: const Text(
        'Sair da Conta',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
