import 'package:flutter/material.dart';

/// Filtro por categoria dos favoritos (chips).
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
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
      child: SizedBox(
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
                      onSelected: (_) => onCategoriaSelecionada(index),
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
    );
  }
}