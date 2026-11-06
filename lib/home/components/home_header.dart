import 'package:flutter/material.dart';

import '../../responsive_content.dart';

/// Header usado na Home e na tela de Buscar.
///
/// - Na Home: o campo funciona como atalho (ao enviar, abre a Buscar).
/// - Na Buscar: o campo filtra os imóveis em tempo real.
class HomeHeader extends StatelessWidget {
  final String nomeUsuario;
  final TextEditingController? controller;
  final ValueChanged<String>? onBuscaAlterada;
  final ValueChanged<String>? onBuscaEnviada;
  final String hintText;
  final bool autofocus;

  const HomeHeader({
    super.key,
    required this.nomeUsuario,
    this.controller,
    this.onBuscaAlterada,
    this.onBuscaEnviada,
    this.hintText = 'Buscar imóveis...',
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final campo = controller;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF963333),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: ResponsiveContent(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $nomeUsuario!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Encontre o imóvel ideal para você',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF963333)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: campo,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              onChanged: onBuscaAlterada,
              onSubmitted: onBuscaEnviada,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF963333),
                  size: 20,
                ),
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
                                  onBuscaAlterada?.call('');
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
            ),
          ],
        ),
      ),
    );
  }
}