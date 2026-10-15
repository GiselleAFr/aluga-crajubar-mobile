import 'package:flutter/material.dart';

class CategoriesSection extends StatelessWidget {
  final List<String> categorias;
  final int categoriaSelecionada;
  final ValueChanged<int> onCategoriaSelecionada;
  const CategoriesSection({super.key, required this.categorias, required this.categoriaSelecionada, required this.onCategoriaSelecionada});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('CATEGORIAS', style: TextStyle(color: Color(0xFF963333), fontSize: 10, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE8D8D1)), borderRadius: BorderRadius.circular(24)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          isExpanded: true, value: 'Casas e Apartamentos',
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF963333)),
          items: const [
            DropdownMenuItem(value: 'Casas e Apartamentos', child: Row(children: [Icon(Icons.home_outlined, color: Color(0xFF963333), size: 18), SizedBox(width: 10), Text('Casas e Apartamentos', style: TextStyle(fontSize: 12))])),
            DropdownMenuItem(value: 'Chalés e Sítios', child: Text('Chalés e Sítios', style: TextStyle(fontSize: 12))),
            DropdownMenuItem(value: 'Fazendas', child: Text('Fazendas', style: TextStyle(fontSize: 12))),
          ],
          onChanged: (_) {},
        )),
      ),
      const SizedBox(height: 10),
      SizedBox(height: 32, child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: categorias.length, separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final selected = categoriaSelecionada == i;
          return ChoiceChip(
            label: Text(categorias[i]), selected: selected, onSelected: (_) => onCategoriaSelecionada(i), showCheckmark: false,
            labelStyle: TextStyle(fontSize: 9, color: selected ? Colors.white : const Color(0xFF333333), fontWeight: FontWeight.w500),
            backgroundColor: Colors.white, selectedColor: const Color(0xFF963333),
            side: BorderSide(color: selected ? const Color(0xFF963333) : const Color(0xFFE8D8D1)),
            padding: const EdgeInsets.symmetric(horizontal: 5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          );
        },
      )),
    ]),
  );
}
