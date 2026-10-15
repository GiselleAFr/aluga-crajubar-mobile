import 'package:flutter/material.dart';

import '../busca/buscar_page.dart';
import 'models/property.dart';
import 'components/home_header.dart';
import 'components/featured_properties.dart';
import 'components/categories_section.dart';
import 'components/home_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  int _categoryIndex = 0;
  String _search = '';
  final _categories = const ['Casas', 'Apartamentos', 'Chalés', 'Fazendas'];

  late final List<Property> _properties = [
    Property(
      nome: 'Pousada Pedra Cinzenta',
      local: 'Juazeiro do Norte',
      preco: 350,
      nota: 4.9,
      categoria: 'Casas',
      imagem:
          'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?w=700',
    ),
    Property(
      nome: 'Quarto Luxuoso - Vista',
      local: 'Juazeiro do Norte',
      preco: 180,
      nota: 4.8,
      categoria: 'Apartamentos',
      imagem:
          'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=700',
    ),
    Property(
      nome: 'Casa de Campo',
      local: 'Crato, Ceará',
      preco: 420,
      nota: 4.9,
      categoria: 'Fazendas',
      imagem:
          'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?w=700',
    ),
    Property(
      nome: 'Chalé da Serra',
      local: 'Barbalha, Ceará',
      preco: 260,
      nota: 4.7,
      categoria: 'Chalés',
      imagem:
          'https://images.unsplash.com/photo-1510798831971-661eb04b3739?w=700',
    ),
  ];

  List<Property> get _filtered => _properties.where((p) {
    final term = _search.trim().toLowerCase();
    return p.categoria == _categories[_categoryIndex] &&
        (term.isEmpty ||
            p.nome.toLowerCase().contains(term) ||
            p.local.toLowerCase().contains(term));
  }).toList();

  void _showProperty(Property p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.nome,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(p.local),
            const SizedBox(height: 12),
            Text(
              'R\$ ${p.preco} por noite',
              style: const TextStyle(
                color: Color(0xFF963333),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF963333),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('A reserva será integrada futuramente.'),
                    ),
                  );
                },
                child: const Text('Continuar reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selecionarNavegacao(int indice) {
    if (indice == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const BuscarPage()));
      return;
    }

    setState(() => _navIndex = indice);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F7F5),
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          HomeHeader(
            nomeUsuario: 'Amanda',
            onBuscaAlterada: (v) => setState(() => _search = v),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeaturedProperties(
                    imoveis: _filtered,
                    onFavoritoPressed: (p) =>
                        setState(() => p.favorito = !p.favorito),
                    onReservarPressed: _showProperty,
                    onVerTodosPressed: () => setState(() {
                      _categoryIndex = 0;
                      _search = '';
                    }),
                  ),
                  CategoriesSection(
                    categorias: _categories,
                    categoriaSelecionada: _categoryIndex,
                    onCategoriaSelecionada: (i) =>
                        setState(() => _categoryIndex = i),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: HomeBottomNavigation(
      indiceSelecionado: _navIndex,
      onItemSelecionado: _selecionarNavegacao,
    ),
  );
}
