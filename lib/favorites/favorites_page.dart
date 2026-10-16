import 'package:flutter/material.dart';

import '../home/models/property.dart';
import '../home/components/home_navigation.dart';
import '../responsive_content.dart';
import 'components/favorites_header.dart';
import 'components/favorites_categories.dart';
import 'components/favorites_property_section.dart';

class FavoritesPage extends StatefulWidget {
  final List<Property> imoveis;
  final String userName;
  final ValueChanged<Property> onFavoritoPressed;
  final ValueChanged<Property> onReservarPressed;
  final ValueChanged<int>? onItemSelecionado;

  const FavoritesPage({
    super.key,
    required this.imoveis,
    this.userName = 'viajante',
    required this.onFavoritoPressed,
    required this.onReservarPressed,
    this.onItemSelecionado,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int categoriaSelecionada = 0;

  final List<String> categorias = const [
    'Casas',
    'Apartamentos',
    'Chalés',
    'Fazendas',
  ];

  List<Property> get imoveisFavoritos {
    return widget.imoveis.where((imovel) {
      return imovel.favorito;
    }).toList();
  }

  List<Property> get imoveisFiltrados {
    final categoria = categorias[categoriaSelecionada];

    return imoveisFavoritos.where((imovel) {
      return imovel.categoria == categoria;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = imoveisFavoritos;
    final filtrados = imoveisFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FavoritesHeader(nomeUsuario: widget.userName),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 1200,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FavoritesCategories(
                        categorias: categorias,
                        categoriaSelecionada: categoriaSelecionada,
                        onCategoriaSelecionada: (index) {
                          setState(() {
                            categoriaSelecionada = index;
                          });
                        },
                      ),

                      FavoritesPropertySection(
                        titulo: 'Destaques',
                        imoveis: filtrados,
                        onFavoritoPressed: _alternarFavorito,
                        onReservarPressed: widget.onReservarPressed,
                        onVerTodosPressed: () {
                          setState(() {
                            categoriaSelecionada = 0;
                          });
                        },
                      ),

                      FavoritesPropertySection(
                        titulo: 'Recentes adicionados à lista',
                        imoveis: favoritos.reversed.toList(),
                        onFavoritoPressed: _alternarFavorito,
                        onReservarPressed: widget.onReservarPressed,
                        onVerTodosPressed: () {
                          setState(() {
                            categoriaSelecionada = 0;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        indiceSelecionado: 2,
        onItemSelecionado: (index) {
          widget.onItemSelecionado?.call(index);
        },
      ),
    );
  }

  void _alternarFavorito(Property imovel) {
    widget.onFavoritoPressed(imovel);
    setState(() {});
  }
}
