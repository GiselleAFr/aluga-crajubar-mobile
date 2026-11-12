import 'package:flutter/material.dart';

import '../responsive_content.dart';
import '../services/notification_service.dart';
import 'notification_center.dart';

/// Tela "Notificações": liga e desliga cada tipo de aviso.
/// As escolhas são gravadas na API (PATCH /notification-preferences).
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _Opcao {
  const _Opcao({
    required this.type,
    required this.titulo,
    required this.descricao,
    this.padrao = true,
    this.emBreve = false,
  });

  final String type;
  final String titulo;
  final String descricao;

  /// Valor exibido enquanto o servidor ainda não tem uma escolha do usuário.
  final bool padrao;

  /// Ainda não existe o recurso que gera esse aviso (a preferência já é salva).
  final bool emBreve;
}

const _push = _Opcao(
  type: 'push',
  titulo: 'Notificações push',
  descricao:
      'Mostra os avisos no topo da tela do celular. Se você desligar, nenhum '
      'aviso aparece.',
);

const _avisos = <_Opcao>[
  _Opcao(
    type: 'booking_update',
    titulo: 'Atualização de reserva',
    descricao:
        'Reserva confirmada, recusada ou cancelada, e novas solicitações nos '
        'seus imóveis.',
  ),
  _Opcao(
    type: 'trip_reminder',
    titulo: 'Lembrete de viagem',
    descricao: 'Um aviso antes do início da sua hospedagem.',
    emBreve: true,
  ),
  _Opcao(
    type: 'host_messages',
    titulo: 'Mensagens de anfitriões',
    descricao: 'Mensagens e respostas dos locadores.',
    emBreve: true,
  ),
  _Opcao(
    type: 'reviews',
    titulo: 'Avaliações',
    descricao: 'Pedidos para avaliar sua hospedagem e respostas às avaliações.',
    emBreve: true,
  ),
  _Opcao(
    type: 'promotions',
    titulo: 'Notificações e promoções',
    descricao: 'Ofertas e novidades da plataforma.',
    padrao: false,
    emBreve: true,
  ),
];

const _email = _Opcao(
  type: 'promotional_emails',
  titulo: 'E-mails promocionais',
  descricao: 'Receber ofertas e novidades por e-mail.',
  padrao: false,
  emBreve: true,
);

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  static const _vinho = Color(0xFF963333);
  static const _borda = Color(0xFFE8D8D1);

  final NotificationService _service = NotificationService();

  Map<String, bool> _valores = {};
  final Set<String> _salvando = {};
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  bool _valor(_Opcao opcao) => _valores[opcao.type] ?? opcao.padrao;

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final preferencias = await _service.getPreferences();
      if (!mounted) return;
      setState(() {
        _valores = {for (final p in preferencias) p.type: p.enabled};
        _carregando = false;
      });
      NotificationCenter.instance.setPushEnabled(_valor(_push));
    } on NotificationApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = error.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar suas preferências.';
        _carregando = false;
      });
    }
  }

  void _aviso(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  /// Aplica a mudança na tela na hora e a envia ao servidor.
  /// Se falhar, volta ao valor anterior e avisa.
  Future<void> _alterar(_Opcao opcao, bool novo) async {
    if (_salvando.contains(opcao.type)) return;

    final anterior = _valor(opcao);
    setState(() {
      _valores[opcao.type] = novo;
      _salvando.add(opcao.type);
    });

    try {
      if (opcao.type == _push.type && novo) {
        final permitido = await NotificationCenter.instance.requestPermission();
        if (!permitido && NotificationCenter.instance.supported && mounted) {
          _aviso(
            'As notificações estão bloqueadas no celular. Ative-as nas '
            'configurações do aparelho.',
          );
        }
      }

      await _service.updatePreferences({opcao.type: novo});

      if (opcao.type == _push.type) {
        NotificationCenter.instance.setPushEnabled(novo);
      }
      if (!mounted) return;
      setState(() => _salvando.remove(opcao.type));
    } on NotificationApiException catch (error) {
      _reverter(opcao, anterior, error.message);
    } catch (_) {
      _reverter(opcao, anterior, 'Não foi possível salvar. Tente novamente.');
    }
  }

  void _reverter(_Opcao opcao, bool anterior, String mensagem) {
    if (!mounted) return;
    setState(() {
      _valores[opcao.type] = anterior;
      _salvando.remove(opcao.type);
    });
    _aviso(mensagem);
  }

  Future<void> _enviarTeste() async {
    final ok = await NotificationCenter.instance.showTest();
    if (!ok && mounted) {
      _aviso(
        'Não foi possível mostrar a notificação. Verifique se elas estão '
        'liberadas para o app nas configurações do celular.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        backgroundColor: _vinho,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildCorpo(),
    );
  }

  Widget _buildCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: _vinho));
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 55, color: Colors.grey),
              const SizedBox(height: 14),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vinho,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final pushLigado = _valor(_push);

    return SingleChildScrollView(
      child: ResponsiveContent(
        maxWidth: 800,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha quais avisos você quer receber.',
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 16),
            _cartao([_linha(_push, ativo: true)]),
            if (NotificationCenter.instance.supported && pushLigado) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _enviarTeste,
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Enviar notificação de teste'),
                  style: TextButton.styleFrom(foregroundColor: _vinho),
                ),
              ),
            ],
            const SizedBox(height: 18),
            _titulo('Avisos no aparelho'),
            if (!pushLigado)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Ative as notificações push para receber estes avisos.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            _cartao([
              for (var i = 0; i < _avisos.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFEFE5E0)),
                _linha(_avisos[i], ativo: pushLigado),
              ],
            ]),
            const SizedBox(height: 22),
            _titulo('E-mail'),
            _cartao([_linha(_email, ativo: true)]),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      texto,
      style: const TextStyle(
        color: _vinho,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _cartao(List<Widget> filhos) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borda),
    ),
    child: Column(children: filhos),
  );

  Widget _linha(_Opcao opcao, {required bool ativo}) {
    final ligado = _valor(opcao);

    return InkWell(
      onTap: ativo ? () => _alterar(opcao, !ligado) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: ativo ? 1 : 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          opcao.titulo,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (opcao.emBreve)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDEDED),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Em breve',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF616161),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      opcao.descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: ligado,
              onChanged: ativo ? (valor) => _alterar(opcao, valor) : null,
              trackColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? _vinho : null,
              ),
              thumbColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}