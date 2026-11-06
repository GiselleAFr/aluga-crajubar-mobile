import 'package:flutter/material.dart';

import '../models/property.dart';
import 'property_grid.dart';

/// Destaques da Home em grade (fileiras), sem rolagem horizontal.
class FeaturedProperties extends StatelessWidget {
  final List<Property> imoveis;
  final ValueChanged<Property> onFavoritoPressed, onReservarPressed;
  final VoidCallback onVerTodosPressed;
  final ValueChanged<Property> onImovelPressed;

  /// Quantidade máxima de imóveis exibidos na Home.
  final int limite;

  const FeaturedProperties({
    super.key,
    required this.imoveis,
    required this.onFavoritoPressed,
    required this.onReservarPressed,
    required this.onVerTodosPressed,
    required this.onImovelPressed,
    this.limite = 8,
  });

  @override
  Widget build(BuildContext context) {
    final destaques = imoveis.take(limite).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESTAQUES',
                        style: TextStyle(
                          color: Color(0xFF963333),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'As melhores opções de aluguel',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onVerTodosPressed,
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
          const SizedBox(height: 10),
          if (destaques.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 18),
              child: Center(
                child: Text(
                  'Nenhum imóvel encontrado.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: PropertyGrid(
                imoveis: destaques,
                onFavoritoPressed: onFavoritoPressed,
                onReservarPressed: onReservarPressed,
                onImovelPressed: onImovelPressed,
              ),
            ),
        ],
      ),
    );
  }
}