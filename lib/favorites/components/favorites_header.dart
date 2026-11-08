import 'package:flutter/material.dart';

import '../../shared/page_header.dart';

/// Mesmo cabeçalho da tela de Reservas, com o texto dos favoritos.
class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({super.key});

  @override
  Widget build(BuildContext context) => const PageHeader(
    titulo: 'Meus Favoritos',
    subtitulo: 'Os imóveis que você salvou para ver depois.',
  );
}