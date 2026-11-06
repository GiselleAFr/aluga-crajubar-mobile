import 'package:flutter/material.dart';

import '../favorites/favorites_page.dart';
import '../favorites/favorites_store.dart';
import '../login/login/login.dart';
import '../profile/profile_page.dart';
import '../search/buscar_page.dart';
import 'models/property.dart';
import 'components/home_header.dart';
import 'components/featured_properties.dart';
import 'components/home_navigation.dart';
import '../responsive_content.dart';
import '../services/auth_service.dart';
import '../services/property_service.dart';
import '../properties/property_details_page.dart';
import '../properties/property_sheet.dart';
import '../reservation/reservations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.user});

  final AuthUser? user;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  final _authService = AuthService();
  final _propertyService = PropertyService();
  final _buscaController = TextEditingController();
  final List<Property> _properties = [];
  int _requestId = 0;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _propertyService.close();
    _authService.close();
    super.dispose();
  }

  void _abrirDetalhes(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailsPage(property: property),
      ),
    );
  }

  Future<void> _fetchProperties() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      // A Home mostra apenas os imóveis para aluguel (destaques).
      final results = await _propertyService.search(finalidade: 'aluguel');
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
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loadError = 'Não foi possível carregar os imóveis.';
        _loading = false;
      });
    }
  }

  /// BottomSheet do imóvel (agora compartilhado com a Buscar).
  void _showProperty(Property p) => showPropertySheet(context, p);

  /// Busca digitada na Home: abre a tela Buscar já com o termo.
  void _buscarNaTelaDeBusca(String valor) {
    final termo = valor.trim();
    _buscaController.clear();
    FocusScope.of(context).unfocus();
    _abrirBusca(termo: termo.isEmpty ? null : termo);
  }

  void _selecionarNavegacao(int indice) {
    switch (indice) {
      case 0:
        setState(() => _navIndex = 0);
        break;
      case 1:
        _abrirBusca();
        break;
      case 2:
        _abrirFavoritos();
        break;
      case 3:
        _abrirReservas();
        break;
      case 4:
        _abrirConta(indice);
        break;
    }
  }

  void _abrirReservas() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReservationsPage(
          onEncontrarHospedagens: _abrirBusca,
          onItemSelecionado: (selectedIndex) {
            Navigator.of(context).pop();
            _selecionarNavegacao(selectedIndex);
          },
        ),
      ),
    );
  }

  void _abrirConta(int indice) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(
          nomeUsuario: widget.user?.name ?? 'viajante',
          user: widget.user,
          authService: _authService,
          indiceSelecionado: indice,
          onLogout: _sairDaConta,
          onItemSelecionado: (selectedIndex) {
            if (selectedIndex == indice) return;

            Navigator.of(context).pop();

            if (selectedIndex == 0) {
              setState(() => _navIndex = 0);
            } else if (selectedIndex == 1) {
              _abrirBusca();
            } else if (selectedIndex == 2) {
              _abrirFavoritos();
            } else if (selectedIndex == 3) {
              _abrirReservas();
            } else if (selectedIndex == 4) {
              _abrirConta(4);
            }
          },
        ),
      ),
    );
  }

  Future<void> _sairDaConta() async {
    try {
      await _authService.logout();
    } catch (error) {
      debugPrint('Não foi possível concluir o logout remoto: $error');
    }

    FavoritesStore.instance.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _abrirBusca({String? termo}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BuscarPage(
          userName: widget.user?.name,
          termoInicial: termo,
          onItemSelecionado: (indice) {
            Navigator.of(context).pop();
            _selecionarNavegacao(indice);
          },
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
          userName: widget.user?.name ?? 'viajante',
          onReservarPressed: _showProperty,
          onItemSelecionado: (selectedIndex) {
            Navigator.of(context).pop();
            _selecionarNavegacao(selectedIndex);
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
            controller: _buscaController,
            onBuscaEnviada: _buscarNaTelaDeBusca,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ResponsiveContent(
                maxWidth: 1200,
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
                                onPressed: _fetchProperties,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListenableBuilder(
                        listenable: FavoritesStore.instance,
                        builder: (context, _) => FeaturedProperties(
                          imoveis: _properties,
                          onFavoritoPressed: FavoritesStore.instance.toggle,
                          onReservarPressed: _showProperty,
                          onVerTodosPressed: _abrirBusca,
                          onImovelPressed: _abrirDetalhes,
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
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