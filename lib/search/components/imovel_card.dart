import 'package:flutter/material.dart';

class ImovelCard extends StatelessWidget {
  final Map<String, dynamic> imovel;
  final VoidCallback onReservar;
  final VoidCallback? onTap;

  const ImovelCard({super.key, required this.imovel, required this.onReservar, this.onTap,});

  @override
  Widget build(BuildContext context) {
    final preco = (imovel['preco'] as num).toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8D2C7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child:
                      (imovel['imagem'] == null ||
                          imovel['imagem'].toString().isEmpty)
                      ? _imagemIndisponivel()
                      : Image.network(
                          imovel['imagem'].toString(),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagemIndisponivel(),
                        ),
                ),
                if (imovel['avaliacao'] is num)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFE5A323),
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            (imovel['avaliacao'] as num).toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imovel['nome'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    imovel['local'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: Color(0xFFA83232),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: ' ${imovel['periodo_preco'] ?? '/mês'}',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    height: 25,
                    child: ElevatedButton(
                      onPressed: onReservar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA83232),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Reservar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagemIndisponivel() => Container(
    width: double.infinity,
    color: const Color(0xFFE9E1DC),
    child: const Center(
      child: Icon(Icons.home_work_outlined, color: Color(0xFFA83232), size: 36),
    ),
  );
}
