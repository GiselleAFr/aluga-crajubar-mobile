import 'package:flutter/material.dart';

import '../favorites/favorites_page.dart';
import '../become_host/become_host_page.dart';
import '../favorites/favorites_store.dart';
import '../help/help_page.dart';
import '../landlord/landlord_property_address_page.dart';
import '../landlord/landlord_properties_page.dart';
import '../landlord/models/landlord_property_draft.dart';
import '../login/login/login.dart';
import '../profile/profile_page.dart';
import '../search/buscar_page.dart';
import '../search/components/secao_imoveis.dart';
import 'models/property.dart';
import 'components/home_header.dart';
import 'components/home_navigation.dart';
import 'components/home_status_card.dart';
import 'components/how_it_works_section.dart';
import 'components/search_invite.dart';
import 'home_status.dart';
import '../responsive_content.dart';
import '../services/auth_service.dart';
import '../services/property_service.dart';
import '../services/reservation_service.dart';
import '../properties/property_details_page.dart';
import '../properties/property_sheet.dart';
import '../reservation/reservations_page.dart';
import '../security/security_page.dart';
import '../notifications/notification_center.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.user});

  final AuthUser? user;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _vinho = Color(0xFF963333);

  /// Quantidade de imóveis em cada seção da Home.
  static const _porSecao = 4;

  int _navIndex = 0;
  final _authService = AuthService();
  final _propertyService = PropertyService();
  final _reservationService = ReservationService();
  final _buscaController = TextEditingController();

  AuthUser? _user;
  bool _isLandlord = false;
  List<Property> _destaques = [];
  List<Property> _recentes = [];
  final List<LandlordPropertyDraft> _landlordProperties = [];
  HomeStatus? _status;
  bool _loading = true;
  String? _loadError;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _isLandlord = widget.user?.isLandlord ?? false;
    // Quando uma solicitação é criada ou cancelada, o card de status atualiza.
    ReservationService.changes.addListener(_carregarStatus);
    _carregarTudo();

    NotificationCenter.instance.start(
      onSelected: (_) { if (mounted) _abrirReservas(); },
    );
  }

  @override
  void dispose() {
    ReservationService.changes.removeListener(_carregarStatus);
    _buscaController.dispose();
    _propertyService.close();
    _reservationService.close();
    _authService.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------------
  Future<void> _carregarTudo({bool silencioso = false}) async {
    await Future.wait([
      _carregarImoveis(silencioso: silencioso),
      _atualizarUsuarioEStatus(),
    ]);
  }

  Future<void> _atualizarUsuarioEStatus() async {
    try {
      final atualizado = await _authService.currentUser();
      if (mounted) {
        setState(() {
          _user = atualizado;
          _isLandlord = _isLandlord || atualizado.isLandlord;
        });
      }
    } catch (_) {
      // Mantém o usuário que veio do login.
    }
    await _carregarStatus();
  }

  Future<void> _carregarImoveis({bool silencioso = false}) async {
    final requestId = ++_requestId;

    if (!silencioso) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      // Só imóveis para aluguel: é o que o app permite reservar.
      final resultados = await Future.wait([
        _propertyService.search(
          finalidade: 'aluguel',
          ordenacao: 'mais_favoritados',
          perPage: 8,
        ),
        _propertyService.search(
          finalidade: 'aluguel',
          ordenacao: 'mais_recentes',
          perPage: 12,
        ),
      ]);

      if (!mounted || requestId != _requestId) return;

      final destaques = resultados[0].take(_porSecao).toList();
      final idsDestaque = destaques.map((p) => p.id).toSet();
      // Um imóvel aparece uma única vez na Home.
      final recentes = resultados[1]
          .where((p) => !idsDestaque.contains(p.id))
          .take(_porSecao)
          .toList();

      setState(() {
        _destaques = destaques;
        _recentes = recentes;
        _loading = false;
        _loadError = null;
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

  /// O card de status é opcional: se algo falhar, ele simplesmente não aparece.
  Future<void> _carregarStatus() async {
    HomeStatus? novo;

    if (_isLandlord) {
      try {
        final pendentes = await _reservationService.getPendingRequestsCount();
        if (pendentes > 0) novo = HomeStatus.landlordPending(pendentes);
      } catch (_) {}
    }

    if (novo == null) {
      try {
        novo = HomeStatus.fromReservations(
          await _reservationService.getReservations(),
        );
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _status = novo);
  }

  // ---------------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------------
  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // Destinos que ainda serão ligados (um ponto de troca para cada um).
  void _abrirAjuda() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HelpPage()));
  }

  void _abrirSeguranca() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecurityPage(authService: _authService),
      ),
    );
  }

  void _abrirSolicitacoesLocador() =>
      _aviso('A tela de solicitações do locador está em desenvolvimento.');

  void _abrirStatus(HomeStatus status) {
    if (status.type == HomeStatusType.landlordPending) {
      _abrirSolicitacoesLocador();
    } else {
      _abrirReservas();
    }
  }

  void _abrirDetalhes(Property property) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailsPage(property: property),
      ),
    );
  }

  /// BottomSheet do imóvel (compartilhado com Buscar e Favoritos).
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
      case 5:
        _abrirImoveisLocador();
        break;
    }
  }

  void _abrirImoveisLocador() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: LandlordPropertiesPage.routeName),
        builder: (_) => LandlordPropertiesPage(
          userName: _user?.name ?? widget.user?.name ?? 'viajante',
          properties: List.unmodifiable(_landlordProperties),
          onPropertiesChanged: (properties) {
            setState(() {
              _landlordProperties
                ..clear()
                ..addAll(properties);
            });
          },
          onAdicionarImovel: (onPropertyCreated) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(
                  name: LandlordPropertyAddressPage.routeName,
                ),
                builder: (_) => LandlordPropertyAddressPage(
                  onPropertyCreated: (property) {
                    onPropertyCreated(property);
                    Navigator.of(context).popUntil(
                      (route) =>
                          route.settings.name ==
                          LandlordPropertiesPage.routeName,
                    );
                    _aviso('Imóvel adicionado à lista de demonstração.');
                  },
                  onItemSelecionado: (indice) {
                    if (indice == 5) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    _selecionarNavegacao(indice);
                  },
                ),
              ),
            );
          },
          onItemSelecionado: (indice) {
            if (indice == 5) return;
            Navigator.of(context).pop();
            _selecionarNavegacao(indice);
          },
        ),
      ),
    );
  }

  void _abrirReservas() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReservationsPage(
          mostrarLocador: _isLandlord,
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
          mostrarLocador: _isLandlord,
          onLogout: _sairDaConta,
          onTornarLocador: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BecomeHostPage(
                  onSubmit: (_) {
                    setState(() => _isLandlord = true);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    _aviso('Cadastro de locador concluído nesta demonstração.');
                  },
                ),
              ),
            );
          },
          onSeguranca: _abrirSeguranca,
          onAjuda: _abrirAjuda,
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
            } else if (selectedIndex == 5) {
              _aviso('A área do locador estará disponível em breve.');
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

    await NotificationCenter.instance.stop();

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
          mostrarLocador: _isLandlord,
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
          mostrarLocador: _isLandlord,
          onReservarPressed: _showProperty,
          onItemSelecionado: (selectedIndex) {
            Navigator.of(context).pop();
            _selecionarNavegacao(selectedIndex);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F7F5),
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          HomeHeader(
            nomeUsuario: _user?.name ?? widget.user?.name ?? 'viajante',
            controller: _buscaController,
            onBuscaEnviada: _buscarNaTelaDeBusca,
          ),
          Expanded(
            child: RefreshIndicator(
              color: _vinho,
              onRefresh: () => _carregarTudo(silencioso: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ResponsiveContent(
                  maxWidth: 1200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: HowItWorksSection(onAjudaPressed: _abrirAjuda),
                      ),
                      if (_status case final status?)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                          child: HomeStatusCard(
                            status: status,
                            onTap: () => _abrirStatus(status),
                          ),
                        ),
                      const SizedBox(height: 22),
                      _buildImoveis(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
                        child: SearchInvite(onPressed: _abrirBusca),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
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
      mostrarLocador: _isLandlord,
    ),
  );

  Widget _buildImoveis() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: _vinho)),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _carregarImoveis,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_destaques.isEmpty && _recentes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 18),
        child: Center(
          child: Text(
            'Nenhum imóvel disponível no momento.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    // Os corações se atualizam sozinhos quando um favorito muda.
    return ListenableBuilder(
      listenable: FavoritesStore.instance,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_destaques.isNotEmpty)
              SecaoImoveis(
                titulo: 'DESTAQUES',
                subtitulo: 'Os mais favoritados pelos hóspedes',
                imoveis: _destaques,
                onVerTodos: _abrirBusca,
                onReservar: _showProperty,
                onImovelPressed: _abrirDetalhes,
                onFavorito: FavoritesStore.instance.toggle,
              ),
            if (_destaques.isNotEmpty && _recentes.isNotEmpty)
              const SizedBox(height: 24),
            if (_recentes.isNotEmpty)
              SecaoImoveis(
                titulo: 'ADICIONADOS RECENTEMENTE',
                subtitulo: 'Novidades para alugar no Crajubar',
                imoveis: _recentes,
                onVerTodos: _abrirBusca,
                onReservar: _showProperty,
                onImovelPressed: _abrirDetalhes,
                onFavorito: FavoritesStore.instance.toggle,
              ),
          ],
        ),
      ),
    );
  }
}
