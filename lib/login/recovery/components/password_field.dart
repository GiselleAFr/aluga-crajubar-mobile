import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onVisibilityPressed;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onVisibilityPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xff555555),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: label,

          hintStyle: const TextStyle(
            color: Color(0xffc99999),
            fontSize: 14,
          ),

          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xffb94b4b),
            size: 18,
          ),

          suffixIcon: IconButton(
            onPressed: onVisibilityPressed,
            icon: Icon(
              obscureText
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: const Color(0xffd19b9b),
              size: 15,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      ),
    );
  }
}