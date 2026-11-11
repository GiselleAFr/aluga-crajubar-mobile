import 'package:flutter/material.dart';

import 'security_colors.dart';

/// Botão principal (preenchido, formato pílula).
class SecurityFilledButton extends StatelessWidget {
  const SecurityFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;

  /// Nulo desabilita o botão.
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SecurityColors.vinho,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SecurityColors.vinho.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// Botão secundário (apenas contorno, formato pílula).
class SecurityOutlinedButton extends StatelessWidget {
  const SecurityOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;

  /// Nulo desabilita o botão.
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null && !isLoading;
    final cor = habilitado
        ? SecurityColors.vinho
        : SecurityColors.vinho.withValues(alpha: 0.45);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: SecurityColors.vinho,
          side: BorderSide(color: cor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SecurityColors.vinho,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
      ),
    );
  }
}
