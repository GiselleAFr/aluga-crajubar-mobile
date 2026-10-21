import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../home/models/property.dart';
import '../home/components/home_navigation.dart';
import 'components/profile_header.dart';
import 'components/profile_summary_card.dart';
import 'components/profile_history_section.dart';
import 'components/profile_settings_section.dart';
import 'components/logout_button.dart';

class ProfilePage extends StatefulWidget {
  final String nomeUsuario;
  final AuthUser? user;
  final AuthService? authService;
  final int indiceSelecionado;
  final List<Property> imoveisHistorico;
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
    this.nomeUsuario = 'Amanda',
    this.user,
    this.authService,
    this.indiceSelecionado = 4,
    this.imoveisHistorico = const [],
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
  late final AuthService _authService;
  late final bool _ownsAuthService;
  AuthUser? _user;

  void _aviso(BuildContext context, String mensagem) {
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
  }

  Future<void> _carregarUsuario() async {
    try {
      final user = await _authService.currentUser();
      if (mounted) setState(() => _user = user);
    } on AuthException catch (error) {
      if (mounted && _user == null) _aviso(context, error.message);
    }
  }

  @override
  void dispose() {
    if (_ownsAuthService) _authService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeUsuario = _user?.name.isNotEmpty == true
        ? _user!.name
        : widget.nomeUsuario;
    final membroDesde = _user?.createdAt == null
        ? 'Membro desde —'
        : 'Membro desde ${_user!.createdAt!.year}';
    final historico = widget.imoveisHistorico;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ProfileHeader(nomeUsuario: nomeUsuario, membroDesde: membroDesde),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileSummaryCard(
                      nomeUsuario: nomeUsuario,
                      email: _user?.email ?? '',
                      telefone: _user?.phone ?? '',
                      onTap:
                          widget.onInformacoesPessoais ??
                          () =>
                              _aviso(context, 'Informações pessoais em breve.'),
                    ),
                    const SizedBox(height: 16),
                    ProfileHistorySection(
                      imoveis: historico,
                      onVerTodos: () => _aviso(
                        context,
                        'O histórico ainda não está disponível.',
                      ),
                      onImovelTap: (imovel) =>
                          _aviso(context, 'Imóvel: ${imovel.nome}'),
                    ),
                    const SizedBox(height: 16),
                    ProfileSettingsSection(
                      onInformacoesPessoais:
                          widget.onInformacoesPessoais ??
                          () =>
                              _aviso(context, 'Informações pessoais em breve.'),
                      onSeguranca:
                          widget.onSeguranca ??
                          () => _aviso(context, 'Segurança e login em breve.'),
                      onNotificacoes:
                          widget.onNotificacoes ??
                          () => _aviso(context, 'Notificações em breve.'),
                      onMetodoPagamento:
                          widget.onMetodoPagamento ??
                          () =>
                              _aviso(context, 'Método de pagamento em breve.'),
                      onTornarLocador:
                          widget.onTornarLocador ??
                          () =>
                              _aviso(context, 'Cadastro de locador em breve.'),
                      onAjuda:
                          widget.onAjuda ??
                          () => _aviso(context, 'Ajuda e suporte em breve.'),
                    ),
                    const SizedBox(height: 17),
                    LogoutButton(
                      onPressed:
                          widget.onLogout ??
                          () => _aviso(
                            context,
                            'Conecte aqui a função de sair da conta.',
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        indiceSelecionado: widget.indiceSelecionado,
        onItemSelecionado: (index) => widget.onItemSelecionado?.call(index),
      ),
    );
  }
}
