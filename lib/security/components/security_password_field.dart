import 'package:flutter/material.dart';

import 'security_colors.dart';

/// Campo de senha com rótulo em negrito acima e olho para mostrar/ocultar.
class SecurityPasswordField extends StatefulWidget {
  const SecurityPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SecurityPasswordField> createState() => _SecurityPasswordFieldState();
}

class _SecurityPasswordFieldState extends State<SecurityPasswordField> {
  bool _oculta = true;

  OutlineInputBorder _borda(Color cor) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: cor),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _oculta,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: SecurityColors.campo,
            hintText: '••••••••••••',
            hintStyle: const TextStyle(color: Colors.black38),
            errorText: widget.errorText,
            errorMaxLines: 3,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _borda(SecurityColors.borda),
            enabledBorder: _borda(SecurityColors.borda),
            disabledBorder: _borda(SecurityColors.borda),
            focusedBorder: _borda(SecurityColors.vinho),
            errorBorder: _borda(Colors.red.shade700),
            focusedErrorBorder: _borda(Colors.red.shade700),
            suffixIcon: IconButton(
              tooltip: _oculta ? 'Mostrar senha' : 'Ocultar senha',
              onPressed: () => setState(() => _oculta = !_oculta),
              icon: Icon(
                _oculta
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: Colors.black45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
