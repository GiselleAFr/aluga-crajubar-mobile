import 'package:flutter/material.dart';

import '../../home/components/property_grid.dart';
import '../../home/models/property.dart';

/// Seção com título, subtítulo e grade de imóveis.
/// Usada na Buscar e nos Favoritos.
class SecaoImoveis extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Property> imoveis;

  /// Quando null, o link "Ver todos" não é exibido.
  final VoidCallback? onVerTodos;
  final ValueChanged<Property> onReservar;
  final ValueChanged<Property> onImovelPressed;
  final ValueChanged<Property> onFavorito;
  final String mensagemVazia;

  const SecaoImoveis({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.imoveis,
    required this.onReservar,
    required this.onImovelPressed,
    required this.onFavorito,
    this.onVerTodos,
    this.mensagemVazia = 'Nenhum imóvel encontrado.',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFFA83232),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onVerTodos != null)
                InkWell(
                  onTap: onVerTodos,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Ver todos',
                      style: TextStyle(
                        color: Color(0xFFA83232),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitulo,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 10),
          if (imoveis.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  mensagemVazia,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            )
          else
            PropertyGrid(
              imoveis: imoveis,
              onFavoritoPressed: onFavorito,
              onReservarPressed: onReservar,
              onImovelPressed: onImovelPressed,
            ),
        ],
      ),
    );
  }
}