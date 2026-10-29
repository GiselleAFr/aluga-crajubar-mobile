import 'package:flutter/material.dart';

import '../models/property.dart';
import 'property_card.dart';

class FeaturedProperties extends StatelessWidget {
  final List<Property> imoveis;
  final ValueChanged<Property> onFavoritoPressed, onReservarPressed;
  final VoidCallback onVerTodosPressed;
  final ValueChanged<Property> onImovelPressed;

  const FeaturedProperties({
    super.key,
    required this.imoveis,
    required this.onFavoritoPressed,
    required this.onReservarPressed,
    required this.onVerTodosPressed,
    required this.onImovelPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
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
        SizedBox(
          height: 230,
          child: imoveis.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum imóvel encontrado.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: imoveis.length,
                  itemBuilder: (context, index) => _card(imoveis[index]),
                ),
        ),
      ],
    ),
  );

  Widget _card(Property property) => PropertyCard(
    property: property,
    onTap: () => onImovelPressed(property),
    onFavoritoPressed: () => onFavoritoPressed(property),
    onReservarPressed: () => onReservarPressed(property),
  );
}
