import 'package:flutter/material.dart';

import '../home/models/property.dart';
import '../home/components/home_navigation.dart';
import '../responsive_content.dart';
import '../search/components/secao_imoveis.dart';
import '../properties/property_details_page.dart';
import 'components/favorites_header.dart';
import 'components/favorites_categories.dart';
import 'favorites_store.dart';

class FavoritesPage extends StatefulWidget {
  final String userName;
  final ValueChanged<Property> onReservarPressed;
  final ValueChanged<int>? onItemSelecionado;

  const FavoritesPage({
    super.key,
    this.userName = 'viajante',
    required this.onReservarPressed,
    this.onItemSelecionado,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  static const _vinho = Color(0xFF963333);

  final FavoritesStore _store = FavoritesStore.instance;
  int categoriaSelecionada = 0;

  final List<String> categorias = const [
    'Todos',
    'Casas',
    'Apartamentos',
    'Quartos e pousadas',
    'Comerciais',
    'Terrenos',
  ];

  void _abrirDetalhes(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailsPage(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FavoritesHeader(nomeUsuario: widget.userName),
            Expanded(
              // Reconstrói sozinho quando um favorito é adicionado/removido.
              child: ListenableBuilder(
                listenable: _store,
                builder: (context, _) {
                  // Mais recentes primeiro.
                  final todos = _store.items.reversed.toList();
                  final categoria = categorias[categoriaSelecionada];
                  final filtrados = categoriaSelecionada == 0
                      ? todos
                      : todos
                            .where((imovel) => imovel.categoria == categoria)
                            .toList();

                  return ResponsiveContent(
                    maxWidth: 1200,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (todos.isEmpty)
                            _buildVazio()
                          else ...[
                            FavoritesCategories(
                              categorias: categorias,
                              categoriaSelecionada: categoriaSelecionada,
                              onCategoriaSelecionada: (index) =>
                                  setState(() => categoriaSelecionada = index),
                            ),
                            const SizedBox(height: 16),
                            SecaoImoveis(
                              titulo: 'MEUS FAVORITOS',
                              subtitulo: filtrados.length == 1
                                  ? '1 imóvel salvo'
                                  : '${filtrados.length} imóveis salvos',
                              imoveis: filtrados,
                              mensagemVazia:
                                  'Nenhum favorito nesta categoria.',
                              onVerTodos: categoriaSelecionada == 0
                                  ? null
                                  : () => setState(
                                      () => categoriaSelecionada = 0,
                                    ),
                              onFavorito: _store.toggle,
                              onReservar: widget.onReservarPressed,
                              onImovelPressed: _abrirDetalhes,
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        indiceSelecionado: 2,
        onItemSelecionado: (index) {
          if (index == 2) return;
          widget.onItemSelecionado?.call(index);
        },
      ),
    );
  }

  Widget _buildVazio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 60, 12, 0),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 72, color: _vinho),
          const SizedBox(height: 16),
          const Text(
            'Nenhum favorito ainda',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no coração de um imóvel para salvá-lo aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => widget.onItemSelecionado?.call(1),
            icon: const Icon(Icons.search),
            label: const Text('Explorar imóveis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _vinho,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}