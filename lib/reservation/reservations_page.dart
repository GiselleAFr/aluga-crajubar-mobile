import 'package:flutter/material.dart';

import '../home/components/home_navigation.dart';
import '../responsive_content.dart';
import '../shared/category_chips.dart';
import '../shared/page_header.dart';
import '../services/reservation_service.dart';
import 'components/reservation_card.dart';
import 'components/reservation_detail_body.dart';
import 'reservation_details_page.dart';
import 'reservation_pricing.dart';

class ReservationsPage extends StatefulWidget {
  final ValueChanged<int> onItemSelecionado;
  final VoidCallback onEncontrarHospedagens;
  final bool mostrarLocador;

  const ReservationsPage({
    super.key,
    required this.onItemSelecionado,
    required this.onEncontrarHospedagens,
    this.mostrarLocador = false,
  });

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  static const _vinho = Color(0xFFA83232);

  static const List<(String, String)> _filtros = [
    ('pending', 'Pendentes'),
    ('confirmed', 'Confirmadas'),
    ('rejected', 'Recusadas'),
    ('cancelled', 'Canceladas'),
  ];

  final ReservationService _service = ReservationService();

  List<Reservation> _reservas = [];
  bool _loading = true;
  String? _error;
  String _filtro = 'pending';
  bool _filtroEscolhido = false;

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

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final lista = await _service.getReservations();
      if (!mounted) return;
      setState(() {
        _reservas = lista;
        _error = null;
        _loading = false;
        if (!_filtroEscolhido) _filtro = _filtroInicial();
      });
    } on ReservationApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar suas reservas.';
        _loading = false;
      });
    }
  }

  /// Hospedagem atual: confirmada e com a data de hoje dentro do período.
  Reservation? get _ativa {
    final hoje = ReservationPricing.dateOnly(DateTime.now());
    final candidatas = _reservas.where((r) {
      final entrada = r.checkIn;
      final saida = r.checkOut;
      return r.status == 'confirmed' &&
          entrada != null &&
          saida != null &&
          !entrada.isAfter(hoje) &&
          saida.isAfter(hoje);
    }).toList()..sort((a, b) => b.checkIn!.compareTo(a.checkIn!));

    return candidatas.isEmpty ? null : candidatas.first;
  }

  /// Reservas de um status, sem repetir a hospedagem atual (já exibida acima).
  List<Reservation> _doStatus(String status) {
    final ativaId = _ativa?.id;
    return _reservas
        .where((r) => r.status == status && r.id != ativaId)
        .toList();
  }

  String _filtroInicial() {
    for (final f in _filtros) {
      if (_doStatus(f.$1).isNotEmpty) return f.$1;
    }
    return 'pending';
  }

  String _textoVazio(String status) => switch (status) {
    'pending' => 'Você não tem solicitações pendentes.',
    'confirmed' => 'Você não tem reservas confirmadas.',
    'rejected' => 'Nenhuma solicitação foi recusada.',
    'cancelled' => 'Você não tem reservas canceladas.',
    _ => 'Nada por aqui.',
  };

  Future<void> _abrirDetalhes(Reservation reserva) async {
    final alterou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ReservationDetailsPage(reservation: reserva),
      ),
    );

    if (alterou == true && mounted) {
      _carregar(silencioso: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        indiceSelecionado: 3,
        mostrarLocador: widget.mostrarLocador,
        onItemSelecionado: (index) {
          if (index == 3) return;
          widget.onItemSelecionado(index);
        },
      ),
    );
  }

  Widget _buildHeader() => const PageHeader(
    titulo: 'Minhas reservas',
    subtitulo: 'Acompanhe suas solicitações e hospedagens.',
  );

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _vinho));
    }
    if (_error != null) return _buildError();
    if (_reservas.isEmpty) return _buildEmptyState();

    final ativa = _ativa;
    final lista = _doStatus(_filtro);

    return RefreshIndicator(
      color: _vinho,
      onRefresh: () => _carregar(silencioso: true),
      child: ResponsiveContent(
        maxWidth: 900,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            if (ativa != null) ...[
              const Text(
                'Hospedagem atual',
                style: TextStyle(
                  color: _vinho,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ReservationDetailBody(reservation: ativa),
              const SizedBox(height: 30),
            ],
            const Text(
              'Minhas solicitações',
              style: TextStyle(
                color: _vinho,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CategoryChips(
              categorias: [
                for (final f in _filtros) '${f.$2} (${_doStatus(f.$1).length})',
              ],
              selecionada: _filtros.indexWhere((f) => f.$1 == _filtro),
              onSelecionar: (index) => setState(() {
                _filtro = _filtros[index].$1;
                _filtroEscolhido = true;
              }),
            ),
            const SizedBox(height: 14),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    _textoVazio(_filtro),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              for (final reserva in lista)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReservationCard(
                    reservation: reserva,
                    onTap: () => _abrirDetalhes(reserva),
                  ),
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 55, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              'Não foi possível carregar suas reservas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
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

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 35),
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E1D9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.travel_explore, size: 100, color: _vinho),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sua próxima hospedagem está esperando por você!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Você ainda não tem reservas. Encontre agora mesmo '
            'o lugar ideal para sua estadia no Crajubar!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onEncontrarHospedagens,
              icon: const Icon(Icons.search),
              label: const Text('Encontrar hospedagens'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _vinho,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
