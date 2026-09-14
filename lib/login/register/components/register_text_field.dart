import 'package:flutter/material.dart';

class RegisterTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool senha;
  final bool mostrarSenha;
  final VoidCallback? onToggleSenha;
  final TextInputType? keyboardType;

  const RegisterTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.senha = false,
    this.mostrarSenha = false,
    this.onToggleSenha,
    this.keyboardType,
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
            color: Colors.black.withOpacity(0.12),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: senha && !mostrarSenha,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xff555555),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: hint,

          hintStyle: const TextStyle(
            color: Color(0xffc99999),
            fontSize: 14,
          ),

          prefixIcon: Icon(
            icon,
            color: const Color(0xffb94b4b),
            size: 18,
          ),

          suffixIcon: senha
              ? IconButton(
                  onPressed: onToggleSenha,
                  icon: Icon(
                    mostrarSenha
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: const Color(0xffd19b9b),
                    size: 15,
                  ),
                )
              : null,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
        ),
      ),
    );
  }
}