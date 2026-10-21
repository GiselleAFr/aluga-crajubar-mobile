import 'package:flutter/material.dart';

import '../../home/models/property.dart';

class ProfileHistorySection extends StatelessWidget {
  final List<Property> imoveis;
  final VoidCallback onVerTodos;
  final ValueChanged<Property> onImovelTap;

  const ProfileHistorySection({
    super.key,
    required this.imoveis,
    required this.onVerTodos,
    required this.onImovelTap,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Histórico',
              style: TextStyle(
                color: Color(0xFF963333),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onVerTodos,
            child: const Text(
              'Ver todos',
              style: TextStyle(
                color: Color(0xFF963333),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (imoveis.isEmpty)
        const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'O histórico ainda não está disponível.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        )
      else
        SizedBox(
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imoveis.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final imovel = imoveis[index];
              return GestureDetector(
                onTap: () => onImovelTap(imovel),
                child: Container(
                  width: 164,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8D8D1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            imovel.imagem ?? '',
                            width: 164,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 164,
                                  height: 68,
                                  color: const Color(0xFFE7DDD6),
                                  child: const Icon(
                                    Icons.home_outlined,
                                    color: Color(0xFF963333),
                                  ),
                                ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '★ ${imovel.nota?.toStringAsFixed(1) ?? '—'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                        child: Text(
                          imovel.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          imovel.local,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          'Jan 2025',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF963333),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    ],
  );
}
