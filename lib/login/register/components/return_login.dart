import 'package:flutter/material.dart';

class ReturnLogin extends StatelessWidget {
  final VoidCallback onPressed;

  const ReturnLogin({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Já tem uma conta? Entrar',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFFA83232),
        ),
      ),
    );
  }
}