import 'package:flutter/material.dart';

import '../../shared/category_chips.dart';

/// Filtro por categoria da tela de Buscar.
class CategoriaImoveis extends StatelessWidget {
  final List<String> categorias;
  final int selecionada;
  final ValueChanged<int> onSelecionar;

  const CategoriaImoveis({
    super.key,
    required this.categorias,
    required this.selecionada,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) => CategoryChips(
    categorias: categorias,
    selecionada: selecionada,
    onSelecionar: onSelecionar,
  );
}