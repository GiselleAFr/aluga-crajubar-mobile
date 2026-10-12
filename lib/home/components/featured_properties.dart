import 'package:flutter/material.dart';
import '../models/property.dart';
import 'property_card.dart';

class FeaturedProperties extends StatelessWidget {
  final List<Property> imoveis;
  final ValueChanged<Property> onFavoritoPressed, onReservarPressed;
  final VoidCallback onVerTodosPressed;
  const FeaturedProperties({super.key, required this.imoveis, required this.onFavoritoPressed, required this.onReservarPressed, required this.onVerTodosPressed});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DESTAQUES', style: TextStyle(color: Color(0xFF963333), fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Text('As melhores opções de aluguel', style: TextStyle(color: Colors.black54, fontSize: 11)),
        ])),
        TextButton(onPressed: onVerTodosPressed, child: const Text('Ver todos', style: TextStyle(color: Color(0xFF963333), fontSize: 11, decoration: TextDecoration.underline))),
      ])),
      const SizedBox(height: 10),
      SizedBox(height: 230, child: imoveis.isEmpty
        ? const Center(child: Text('Nenhum imóvel encontrado.', style: TextStyle(color: Colors.black54)))
        : ListView.builder(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 18), itemCount: imoveis.length,
          itemBuilder: (context, i) => PropertyCard(property: imoveis[i], onFavoritoPressed: () => onFavoritoPressed(imoveis[i]), onReservarPressed: () => onReservarPressed(imoveis[i])),
        )),
    ]),
  );
}
