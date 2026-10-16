import 'package:flutter/material.dart';

class FavoritesHeader extends StatelessWidget {
  final String nomeUsuario;

  const FavoritesHeader({super.key, required this.nomeUsuario});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF963333),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Olá, $nomeUsuario!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF963333)),
          ),
        ],
      ),
    );
  }
}
