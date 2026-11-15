import 'package:flutter/material.dart';

/// Convite final da Home para quem ainda não achou o imóvel ideal.
class SearchInvite extends StatelessWidget {
  const SearchInvite({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const _vinho = Color(0xFFA83232);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D8D1)),
      ),
      child: Column(
        children: [
          const Text(
            'Quer pesquisar melhor?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vá para a busca e encontre o imóvel ideal para a melhor '
            'hospedagem.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.search),
              label: const Text('Ir para a busca'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _vinho,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
