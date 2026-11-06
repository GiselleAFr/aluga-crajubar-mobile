import 'package:flutter/material.dart';

/// Cabeçalho padrão das telas internas (Reservas, Favoritos...).
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.titulo, required this.subtitulo});

  final String titulo;
  final String subtitulo;

  static const _vinho = Color(0xFF963333);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 28),
      decoration: const BoxDecoration(
        color: _vinho,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitulo,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: _vinho, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}