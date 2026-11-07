import 'dart:async';

import 'package:flutter/material.dart';

import 'components/categoria_imoveis.dart';
import 'components/secao_imoveis.dart';
import '../shared/page_header.dart';
import '../shared/search_field.dart';
import '../home/components/home_navigation.dart';
import '../services/property_service.dart';
import '../responsive_content.dart';
import '../home/models/property.dart';
import '../properties/property_details_page.dart';
import '../properties/property_sheet.dart';
import '../favorites/favorites_store.dart';

class BuscarPage extends StatefulWidget {
  const BuscarPage({
    super.key,
    this.userName,
    this.termoInicial,
    required this.onFavoritosPressed,
    this.onItemSelecionado,
  });

  final String? userName;

  /// Termo vindo da busca da Home (a pesquisa já abre preenchida).
  final String? termoInicial;
  final VoidCallback onFavoritosPressed;
  final ValueChanged<int>? onItemSelecionado;

  @override
  State<BuscarPage> createState() => _BuscarPageState();
}

class _BuscarPageState extends State<BuscarPage> {
  late final TextEditingController buscaController;
  final PropertyService _propertyService = PropertyService();
  Timer? _searchDebounce;
  int _requestId = 0;
  bool _loading = true;
  String? _loadError;
  List<Property> imoveis = [];

  int categoriaSelecionada = 0;
  int indiceSelecionado = 1;

  final List<String> categorias = [
    'Todos',
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

  /// Há texto digitado ou categoria diferente de "Todos"?
  bool get _temFiltro =>
      categoriaSelecionada != 0 || buscaController.text.trim().isNotEmpty;

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
    buscaController = TextEditingController(text: widget.termoInicial ?? '');
    _loadProperties();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _propertyService.close();
    buscaController.dispose();
    super.dispose();
  }

  /// Espera o usuário parar de digitar antes de consultar a API.
  void _agendarBusca() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      _loadProperties,
    );
  }

  Future<void> _loadProperties() async {
    _searchDebounce?.cancel();
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
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loadError = 'Não foi possível carregar os imóveis.';
        _loading = false;
      });
    }
  }

  void selecionarCategoria(int indice) {
    setState(() => categoriaSelecionada = indice);
    _loadProperties();
  }

  void _limparFiltros() {
    buscaController.clear();
    setState(() => categoriaSelecionada = 0);
    _loadProperties();
  }

  void selecionarNavegacao(int indice) {
    if (indice == indiceSelecionado) return;

    if (widget.onItemSelecionado != null) {
      widget.onItemSelecionado!(indice);
      return;
    }

    if (indice == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    if (indice == 2) {
      widget.onFavoritosPressed();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Esta seção ainda não está disponível.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = imoveis.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(
              titulo: 'Buscar imóveis',
              subtitulo: 'Encontre o imóvel ideal para a sua hospedagem.',
              child: SearchField(
                controller: buscaController,
                onChanged: (_) => _agendarBusca(),
                onSubmitted: (_) => _loadProperties(),
              ),
            ),
            Expanded(
              child: ResponsiveContent(
                maxWidth: 1200,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  padding: EdgeInsets.zero,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CategoriaImoveis(
                        categorias: categorias,
                        selecionada: categoriaSelecionada,
                        onSelecionar: selecionarCategoria,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                    else
                      SecaoImoveis(
                        titulo: 'RESULTADOS',
                        subtitulo: total == 1
                            ? '1 imóvel encontrado'
                            : '$total imóveis encontrados',
                        imoveis: imoveis,
                        onImovelPressed: _abrirDetalhes,
                        onVerTodos: _temFiltro ? _limparFiltros : null,
                        onReservar: (imovel) =>
                            showPropertySheet(context, imovel),
                        onFavorito: (imovel) => setState(
                          () => FavoritesStore.instance.toggle(imovel),
                        ),
                      ),
                    const SizedBox(height: 16),
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