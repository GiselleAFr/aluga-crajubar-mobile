import 'package:flutter/material.dart';

/// Campo de busca arredondado, usado dentro dos headers da Home e da Buscar.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Buscar imóveis...',
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final campo = controller;

    return TextField(
      controller: campo,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF963333),
          size: 20,
        ),
        // Botão de limpar, só quando há texto.
        suffixIcon: campo == null
            ? null
            : ValueListenableBuilder<TextEditingValue>(
                valueListenable: campo,
                builder: (context, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.grey,
                        onPressed: () {
                          campo.clear();
                          onChanged?.call('');
                        },
                      ),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}