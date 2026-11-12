import 'package:flutter/material.dart';

import '../favorites/favorites_store.dart';
import '../home/components/home_navigation.dart';
import '../reservation/reservation_details_page.dart';
import '../reservation/reservation_pricing.dart';
import '../responsive_content.dart';
import '../services/auth_service.dart';
import '../services/reservation_service.dart';
import '../utils/formatters.dart';
import 'components/logout_button.dart';
import 'components/profile_header.dart';
import 'components/profile_history_section.dart';
import 'components/profile_settings_section.dart';
import 'components/profile_summary_card.dart';
import 'components/history_page.dart';

class ProfilePage extends StatefulWidget {
  final String nomeUsuario;
  final AuthUser? user;
  final AuthService? authService;
  final int indiceSelecionado;
  final bool mostrarLocador;
  final ValueChanged<int>? onItemSelecionado;
  final VoidCallback? onLogout;
  final VoidCallback? onInformacoesPessoais;
  final VoidCallback? onSeguranca;
  final VoidCallback? onNotificacoes;
  final VoidCallback? onMetodoPagamento;
  final VoidCallback? onTornarLocador;
  final VoidCallback? onAjuda;

  const ProfilePage({
    super.key,
    this.nomeUsuario = 'viajante',
    this.user,
    this.authService,
    this.indiceSelecionado = 4,
    this.mostrarLocador = false,
    this.onItemSelecionado,
    this.onLogout,
    this.onInformacoesPessoais,
    this.onSeguranca,
    this.onNotificacoes,
    this.onMetodoPagamento,
    this.onTornarLocador,
    this.onAjuda,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _vinho = Color(0xFFA83232);

  /// Quantas hospedagens aparecem no perfil antes do "Ver todos".
  static const _limiteHistorico = 5;

  late final AuthService _authService;
  late final bool _ownsAuthService;
  final ReservationService _reservationService = ReservationService();

  AuthUser? _user;
  List<Reservation> _reservas = [];
  bool _carregandoReservas = true;
  String? _erroReservas;

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _ownsAuthService = widget.authService == null;
    _authService = widget.authService ?? AuthService();
    _carregarUsuario();
    _carregarReservas();
  }

  @override
  void dispose() {
    if (_ownsAuthService) _authService.close();
    _reservationService.close();
    super.dispose();
  }

  Future<void> _carregarUsuario() async {
    try {
      final user = await _authService.currentUser();
      if (mounted) setState(() => _user = user);
    } on AuthException catch (error) {
      if (mounted && _user == null) _aviso(error.message);
    } catch (_) {
      // Mantém os dados que vieram do login.
    }
  }

  Future<void> _carregarReservas({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _carregandoReservas = true;
        _erroReservas = null;
      });
    }

    try {
      final lista = await _reservationService.getReservations();
      if (!mounted) return;
      setState(() {
        _reservas = lista;
        _carregandoReservas = false;
        _erroReservas = null;
      });
    } on ReservationApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroReservas = error.message;
        _carregandoReservas = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroReservas = 'Não foi possível carregar o histórico.';
        _carregandoReservas = false;
      });
    }
  }

  Future<void> _atualizar() async {
    await Future.wait([
      _carregarUsuario(),
      _carregarReservas(silencioso: true),
    ]);
  }

  /// Hospedagens concluídas: confirmadas e com a saída já ocorrida.
  /// A mais recente primeiro.
  List<Reservation> get _historico {
    final hoje = ReservationPricing.dateOnly(DateTime.now());
    return _reservas
        .where(
          (r) =>
              r.status == 'confirmed' &&
              r.checkOut != null &&
              !r.checkOut!.isAfter(hoje),
        )
        .toList()
      ..sort((a, b) => b.checkOut!.compareTo(a.checkOut!));
  }

  int get _pendentes {
    final hoje = ReservationPricing.dateOnly(DateTime.now());
    return _reservas
        .where(
          (r) =>
              r.status == 'pending' &&
              r.checkIn != null &&
              !r.checkIn!.isBefore(hoje),
        )
        .length;
  }

  void _abrirEstadia(Reservation reserva) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReservationDetailsPage(reservation: reserva),
      ),
    );
  }

  void _abrirHistoricoCompleto() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryPage(estadias: _historico),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = _user?.name.isNotEmpty == true
        ? _user!.name
        : widget.nomeUsuario;

    final criadoEm = _user?.createdAt;
    final membroDesde = criadoEm == null
        ? 'Membro desde —'
        : 'Membro desde ${dataPorExtenso(criadoEm.toLocal())}';

    final historico = _historico;
    final temDados = !_carregandoReservas && _erroReservas == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ProfileHeader(nomeUsuario: nomeUsuario, membroDesde: membroDesde),
            Expanded(
              child: RefreshIndicator(
                color: _vinho,
                onRefresh: _atualizar,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ResponsiveContent(
                    maxWidth: 800,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileSummaryCard(
                          nomeUsuario: nomeUsuario,
                          email: _user?.email ?? '',
                          telefone: _user?.phone ?? '',
                          papel: _user?.role,
                          hospedagens: temDados ? historico.length : null,
                          pendentes: temDados ? _pendentes : null,
                          favoritos: FavoritesStore.instance.count,
                          onTap: widget.onInformacoesPessoais,
                        ),
                        const SizedBox(height: 22),
                        ProfileHistorySection(
                          estadias: historico.take(_limiteHistorico).toList(),
                          carregando: _carregandoReservas,
                          erro: _erroReservas,
                          onTentarNovamente: _carregarReservas,
                          onVerTodos: historico.length > _limiteHistorico
                              ? _abrirHistoricoCompleto
                              : null,
                          onTap: _abrirEstadia,
                        ),
                        const SizedBox(height: 22),
                        ProfileSettingsSection(
                          onInformacoesPessoais:
                              widget.onInformacoesPessoais ??
                              () => _aviso('Informações pessoais em breve.'),
                          onSeguranca:
                              widget.onSeguranca ??
                              () => _aviso('Segurança e login em breve.'),
                          onNotificacoes:
                              widget.onNotificacoes ??
                              () => _aviso('Notificações em breve.'),
                          onMetodoPagamento:
                              widget.onMetodoPagamento ??
                              () => _aviso('Método de pagamento em breve.'),
                          onTornarLocador:
                              widget.onTornarLocador ??
                              () => _aviso('Cadastro de locador em breve.'),
                          onAjuda:
                              widget.onAjuda ??
                              () => _aviso('Ajuda e suporte em breve.'),
                        ),
                        const SizedBox(height: 20),
                        LogoutButton(
                          onPressed:
                              widget.onLogout ??
                              () => _aviso(
                                'Conecte aqui a função de sair da conta.',
                              ),
                        ),
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
        indiceSelecionado: widget.indiceSelecionado,
        onItemSelecionado: (index) => widget.onItemSelecionado?.call(index),
        mostrarLocador: widget.mostrarLocador,
      ),
    );
  }
}
