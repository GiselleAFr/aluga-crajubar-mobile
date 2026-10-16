import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String nomeUsuario;
  final ValueChanged<String> onBuscaAlterada;
  const HomeHeader({
    super.key,
    required this.nomeUsuario,
    required this.onBuscaAlterada,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
    decoration: const BoxDecoration(
      color: Color(0xFF963333),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
    ),
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
          onChanged: onBuscaAlterada,
          decoration: InputDecoration(
            hintText: 'Buscar imóveis...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF963333),
              size: 20,
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
  );
}
