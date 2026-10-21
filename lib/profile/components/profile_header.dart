import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String nomeUsuario;
  final String membroDesde;
  const ProfileHeader({
    super.key,
    required this.nomeUsuario,
    this.membroDesde = 'Membro desde 2023',
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              radius: 17,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF963333), size: 20),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          membroDesde,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
  );
}
