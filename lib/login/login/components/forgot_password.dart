import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  final VoidCallback onPressed;

  const ForgotPassword({
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
        'Esqueceu a senha?',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFFA83232),
        ),
      ),
    );
  }
}