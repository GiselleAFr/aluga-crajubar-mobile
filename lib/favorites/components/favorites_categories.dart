import 'package:flutter/material.dart';

class FavoritesCategories extends StatelessWidget {
  final List<String> categorias;
  final int categoriaSelecionada;
  final ValueChanged<int> onCategoriaSelecionada;

  const FavoritesCategories({
    super.key,
    required this.categorias,
    required this.categoriaSelecionada,
    required this.onCategoriaSelecionada,
  });

  static const Color vinho = Color(0xFF963333);
  static const Color borda = Color(0xFFE8D8D1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favoritos',
            style: TextStyle(
              color: vinho,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borda),
              borderRadius: BorderRadius.circular(22),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Casas e Apartamentos',
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: vinho,
                  size: 18,
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                items: const [
                  DropdownMenuItem(
                    value: 'Casas e Apartamentos',
                    child: Row(
                      children: [
                        Icon(Icons.home_outlined, size: 15, color: vinho),
                        SizedBox(width: 8),
                        Text('Casas e Apartamentos'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Chalés e Sítios',
                    child: Text('Chalés e Sítios'),
                  ),
                  DropdownMenuItem(value: 'Fazendas', child: Text('Fazendas')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(categorias.length, (index) {
                      final selecionada = categoriaSelecionada == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          label: Text(categorias[index], maxLines: 1),
                          selected: selecionada,
                          onSelected: (_) {
                            onCategoriaSelecionada(index);
                          },
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: selecionada ? Colors.white : Colors.black87,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: vinho,
                          side: BorderSide(color: selecionada ? vinho : borda),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
