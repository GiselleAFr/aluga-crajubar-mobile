import 'package:flutter/material.dart';

import '../models/property.dart';
import 'property_card.dart';

/// Grade de cards (fileiras) usada em Home, Buscar e Favoritos.
/// 2 colunas no celular; mais colunas em telas largas.
class PropertyGrid extends StatelessWidget {
  final List<Property> imoveis;
  final ValueChanged<Property> onFavoritoPressed;
  final ValueChanged<Property> onReservarPressed;
  final ValueChanged<Property> onImovelPressed;

  const PropertyGrid({
    super.key,
    required this.imoveis,
    required this.onFavoritoPressed,
    required this.onReservarPressed,
    required this.onImovelPressed,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const spacing = 12.0;
      final colunas = (constraints.maxWidth / 170).floor().clamp(2, 4).toInt();
      // floorToDouble evita estourar a linha por arredondamento.
      final largura =
          ((constraints.maxWidth - spacing * (colunas - 1)) / colunas)
              .floorToDouble();
      final alturaImagem = (largura * 0.66).clamp(104.0, 170.0);

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: imoveis
            .map(
              (property) => SizedBox(
                width: largura,
                child: PropertyCard(
                  property: property,
                  width: null,
                  margin: EdgeInsets.zero,
                  imageHeight: alturaImagem,
                  onTap: () => onImovelPressed(property),
                  onFavoritoPressed: () => onFavoritoPressed(property),
                  onReservarPressed: () => onReservarPressed(property),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}