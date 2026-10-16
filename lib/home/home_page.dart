import 'dart:async';

import 'package:flutter/material.dart';

import '../favorites/favorites_page.dart';
import '../profile/account_page.dart';
import '../search/buscar_page.dart';
import 'models/property.dart';
import 'components/home_header.dart';
import 'components/featured_properties.dart';
import 'components/categories_section.dart';
import 'components/home_navigation.dart';
import '../services/auth_service.dart';
import '../services/property_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.user});

  final AuthUser? user;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  int _categoryIndex = 0;
  String _search = '';
  final _categories = const [
    'Casas',
    'Apartamentos',
    'Quartos e pousadas',
    'Comerciais',
    'Terrenos',
  ];
  final _propertyService = PropertyService();
  final List<Property> _properties = [];
  Timer? _searchDebounce;
  int _requestId = 0;
  bool _loading = true;
  String? _loadError;

  String get _selectedTypes => switch (_categories[_categoryIndex]) {
    'Casas' => 'casa',
    'Apartamentos' => 'apartamento',
    'Quartos e pousadas' => 'quarto,pousada,kitnet',
    'Comerciais' => 'comercial',
    'Terrenos' => 'terreno',
    _ => '',
  };

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _propertyService.close();
    super.dispose();
  }

  void _loadProperties({bool debounce = false}) {
    _searchDebounce?.cancel();
    if (debounce) {
      _searchDebounce = Timer(
        const Duration(milliseconds: 350),
        _fetchProperties,
      );
      return;
    }
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await _propertyService.search(
        query: _search,
        types: _selectedTypes,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _properties
          ..clear()
          ..addAll(results);
        _loading = false;
      });
    } on PropertyApiException catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loadError = error.message;
        _loading = false;
      });
    }
  }

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
              'R\$ ${p.preco.toStringAsFixed(2).replaceAll('.', ',')} ${p.periodoPreco}',
              style: const TextStyle(
                color: Color(0xFF963333),
                fontSize: 16,
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
      _abrirBusca();
      return;
    }

    if (indice == 2) {
      _abrirFavoritos();
      return;
    }

    if (indice == 3 || indice == 4) {
      _abrirConta(indice);
      return;
    }

    setState(() => _navIndex = indice);
  }

  void _abrirConta(int indice) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountPage(
          initialNavigationIndex: indice,
          onNavigate: (selectedIndex) {
            Navigator.of(context).pop();
            if (selectedIndex == 1) {
              _abrirBusca();
            } else if (selectedIndex == 2) {
              _abrirFavoritos();
            }
          },
        ),
      ),
    );
  }

  void _abrirBusca() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuscarPage(
          userName: widget.user?.name,
          onFavoritosPressed: () {
            Navigator.of(context).pop();
            _abrirFavoritos();
          },
        ),
      ),
    );
  }

  void _abrirFavoritos() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FavoritesPage(
          imoveis: _properties,
          userName: widget.user?.name ?? 'viajante',
          onFavoritoPressed: (property) =>
              setState(() => property.favorito = !property.favorito),
          onReservarPressed: _showProperty,
          onItemSelecionado: (selectedIndex) {
            if (selectedIndex == 0) {
              Navigator.of(context).pop();
            } else if (selectedIndex == 1) {
              Navigator.of(context).pop();
              _abrirBusca();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F7F5),
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          HomeHeader(
            nomeUsuario: widget.user?.name ?? 'viajante',
            onBuscaAlterada: (value) {
              setState(() => _search = value);
              _loadProperties(debounce: true);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Text(_loadError!, textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadProperties,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    FeaturedProperties(
                      imoveis: _properties,
                      onFavoritoPressed: (property) => setState(
                        () => property.favorito = !property.favorito,
                      ),
                      onReservarPressed: _showProperty,
                      onVerTodosPressed: () {
                        setState(() {
                          _categoryIndex = 0;
                          _search = '';
                        });
                        _loadProperties();
                      },
                    ),
                  CategoriesSection(
                    categorias: _categories,
                    categoriaSelecionada: _categoryIndex,
                    onCategoriaSelecionada: (index) {
                      setState(() => _categoryIndex = index);
                      _loadProperties();
                    },
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
