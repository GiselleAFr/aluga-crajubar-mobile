import 'dart:async';

import 'package:flutter/material.dart';

import 'components/buscar_header.dart';
import 'components/campo_busca.dart';
import 'components/categoria_imoveis.dart';
import 'components/secao_imoveis.dart';
import '../home/components/home_navigation.dart';
import '../services/property_service.dart';
import '../responsive_content.dart';
import '../home/models/property.dart';
import '../properties/property_details_page.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({
    super.key,
    this.userName,
    required this.onFavoritosPressed,
    this.onItemSelecionado,
  });

  final String? userName;
  final VoidCallback onFavoritosPressed;
  final ValueChanged<int>? onItemSelecionado;
  

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  final TextEditingController buscaController = TextEditingController();
  final PropertyService _propertyService = PropertyService();
  Timer? _searchDebounce;
  int _requestId = 0;
  bool _loading = true;
  String? _loadError;
  List<Property> imoveis = [];

  int categoriaSelecionada = 0;
  int indiceSelecionado = 1;

  final List<String> categorias = [
    'Casas',
    'Apartamentos',
    'Quartos e pousadas',
    'Comerciais',
    'Terrenos',
  ];

  String get _selectedTypes => switch (categorias[categoriaSelecionada]) {
    'Casas' => 'casa',
    'Apartamentos' => 'apartamento',
    'Quartos e pousadas' => 'quarto,pousada,kitnet',
    'Comerciais' => 'comercial',
    'Terrenos' => 'terreno',
    _ => '',
  };

  void _abrirDetalhes(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailsPage(property: property),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties({bool debounce = false}) async {
    _searchDebounce?.cancel();
    if (debounce) {
      _searchDebounce = Timer(
        const Duration(milliseconds: 350),
        () => _loadProperties(),
      );
      return;
    }
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final properties = await _propertyService.search(
        query: buscaController.text,
        types: _selectedTypes,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        imoveis = properties;
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _propertyService.close();
    buscaController.dispose();
    super.dispose();
  }

  void selecionarCategoria(int indice) {
    setState(() {
      categoriaSelecionada = indice;
    });
    _loadProperties();
  }

  void selecionarNavegacao(int indice) {
    if (widget.onItemSelecionado != null) {
      widget.onItemSelecionado!(indice);
      return;
    }

    if (indice == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    if (indice == 2 && widget.onFavoritosPressed != null) {
      widget.onFavoritosPressed!();
      return;
    }

    if (indice != indiceSelecionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta seção ainda não está disponível.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final encontrados = imoveis;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BuscarHeader(userName: widget.userName),

            Expanded(
              child: ResponsiveContent(
                maxWidth: 1200,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: const Text(
                        'Buscar Imóveis',
                        style: TextStyle(
                          color: Color(0xFFA83232),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CampoBusca(
                        controller: buscaController,
                        onChanged: (_) => _loadProperties(debounce: true),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CategoriaImoveis(
                        categorias: categorias,
                        selecionada: categoriaSelecionada,
                        onSelecionar: selecionarCategoria,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Text(_loadError!, textAlign: TextAlign.center),
                              TextButton(
                                onPressed: _loadProperties,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      SecaoImoveis(
                        titulo: 'DESTAQUES',
                        subtitulo: 'As melhores opções de aluguel',
                        imoveis: encontrados,
                        onImovelPressed: _abrirDetalhes,
                        onVerTodos: () {},
                        onReservar: (imovel) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Imóvel selecionado: ${imovel.nome}'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      SecaoImoveis(
                        titulo: 'PERTO DE VOCÊ',
                        subtitulo: 'As melhores opções da região',
                        imoveis: encontrados.reversed.toList(),
                        onImovelPressed: _abrirDetalhes,
                        onVerTodos: () {},
                        onReservar: (imovel) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Imóvel selecionado: ${imovel.nome}'),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        indiceSelecionado: indiceSelecionado,
        onItemSelecionado: selecionarNavegacao,
      ),
    );
  }
}
