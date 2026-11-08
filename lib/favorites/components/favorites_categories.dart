import 'package:flutter/material.dart';

import '../../shared/category_chips.dart';

/// Filtro por categoria dos favoritos.
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
      child: CategoryChips(
        categorias: categorias,
        selecionada: categoriaSelecionada,
        onSelecionar: onCategoriaSelecionada,
      ),
    );
  }
}
