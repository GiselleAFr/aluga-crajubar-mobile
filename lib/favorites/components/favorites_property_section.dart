import 'package:flutter/material.dart';

import '../../home/models/property.dart';
import '../../home/components/property_card.dart';

class FavoritesPropertySection extends StatelessWidget {
  final String titulo;
  final List<Property> imoveis;
  final ValueChanged<Property> onFavoritoPressed;
  final ValueChanged<Property> onReservarPressed;
  final VoidCallback onVerTodosPressed;
  final ValueChanged<Property> onImovelPressed;

  const FavoritesPropertySection({
    super.key,
    required this.titulo,
    required this.imoveis,
    required this.onFavoritoPressed,
    required this.onReservarPressed,
    required this.onVerTodosPressed,
    required this.onImovelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF963333),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'As melhores opções de aluguel',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onVerTodosPressed,
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
          ),
          const SizedBox(height: 8),

          if (imoveis.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Nenhum imóvel favorito nesta seção.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 700) {
                  final columns = (constraints.maxWidth / 250)
                      .floor()
                      .clamp(2, 4)
                      .toInt();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 300,
                    ),
                    itemCount: imoveis.length,
                    itemBuilder: (context, index) => _card(imoveis[index]),
                  );
                }

                return SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: imoveis.length,
                    itemBuilder: (context, index) =>
                        SizedBox(width: 184, child: _card(imoveis[index])),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _card(Property imovel) => PropertyCard(
    property: imovel,
    onFavoritoPressed: () => onFavoritoPressed(imovel),
    onReservarPressed: () => onReservarPressed(imovel),
    onTap: () => onImovelPressed(imovel),
  );
}
