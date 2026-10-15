import 'package:flutter/material.dart';

class BuscarHeader extends StatelessWidget {
  const BuscarHeader({super.key, this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
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
                      'Olá, ${userName ?? 'viajante'}!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Encontre o imóvel ideal para você.',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFFA83232), size: 24),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                SizedBox(width: 12),
                Icon(Icons.search, color: Color(0xFFA83232), size: 19),
                SizedBox(width: 8),
                Text(
                  'Buscar imóveis...',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
