import 'package:flutter/material.dart';

import '../home/models/property.dart';
import '../services/reservation_service.dart';
import 'reservation_pricing.dart';

/// Tela de solicitação de reserva.
/// Reutilizável: basta receber um [Property] (Home, Busca ou Favoritos).
class ReservationRequestPage extends StatefulWidget {
  const ReservationRequestPage({super.key, required this.property});

  final Property property;

  @override
  State<ReservationRequestPage> createState() => _ReservationRequestPageState();
}

class _ReservationRequestPageState extends State<ReservationRequestPage> {
  static const _primary = Color(0xFFA83232);
  static const _maxHospedes = 20;
  static const _maxMeses = 12;

  final ReservationService _service = ReservationService();

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _meses = 1;
  int _hospedes = 1;

  bool _enviando = false;
  String? _erro;
  Reservation? _resultado;

  Property get _p => widget.property;
  bool get _mensal => _p.isMensal;
  String get _modalidade => _mensal ? 'mensal' : 'diaria';

  int? get _unidades => (_checkIn == null || _checkOut == null)
      ? null
      : ReservationPricing.unidades(_modalidade, _checkIn!, _checkOut!);

  double? get _total {
    final qtd = _unidades;
    return qtd == null ? null : _p.preco * qtd;
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Seleção de datas
  // ---------------------------------------------------------------------------
  Widget _tema(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: _primary),
      ),
      child: child!,
    );
  }

  Future<void> _escolherPeriodoDiaria() async {
    final hoje = ReservationPricing.dateOnly(DateTime.now());

    final range = await showDateRangePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 730)),
      initialDateRange: (_checkIn != null && _checkOut != null)
          ? DateTimeRange(start: _checkIn!, end: _checkOut!)
          : null,
      helpText: 'Selecione check-in e check-out',
      saveText: 'Confirmar',
      builder: _tema,
    );

    if (range == null) return;

    setState(() {
      _checkIn = ReservationPricing.dateOnly(range.start);
      _checkOut = ReservationPricing.dateOnly(range.end);
      _erro = null;
    });
  }

  Future<void> _escolherCheckInMensal() async {
    final hoje = ReservationPricing.dateOnly(DateTime.now());

    final data = await showDatePicker(
      context: context,
      initialDate: _checkIn ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 730)),
      helpText: 'Data de entrada',
      builder: _tema,
    );

    if (data == null) return;

    setState(() {
      _checkIn = ReservationPricing.dateOnly(data);
      _checkOut = ReservationPricing.checkOutMensal(_checkIn!, _meses);
      _erro = null;
    });
  }

  void _alterarMeses(int delta) {
    final novo = (_meses + delta).clamp(1, _maxMeses);
    setState(() {
      _meses = novo;
      if (_checkIn != null) {
        _checkOut = ReservationPricing.checkOutMensal(_checkIn!, _meses);
      }
      _erro = null;
    });
  }

  void _alterarHospedes(int delta) {
    setState(() {
      _hospedes = (_hospedes + delta).clamp(1, _maxHospedes);
      _erro = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Validação e envio
  // ---------------------------------------------------------------------------
  String? _validar() {
    if (!_p.aceitaReserva) {
      return 'Este imóvel não está disponível para reserva.';
    }
    if (_checkIn == null || _checkOut == null) {
      return _mensal
          ? 'Selecione a data de entrada.'
          : 'Selecione as datas de check-in e check-out.';
    }

    final hoje = ReservationPricing.dateOnly(DateTime.now());
    if (_checkIn!.isBefore(hoje)) {
      return 'A data de entrada não pode ser anterior a hoje.';
    }
    if (!_checkOut!.isAfter(_checkIn!)) {
      return 'O check-out deve ser depois do check-in.';
    }

    final qtd = _unidades;
    if (qtd == null || qtd < 1) {
      return _mensal
          ? 'A reserva mensal deve corresponder a meses completos.'
          : 'A reserva deve ter pelo menos uma diária.';
    }
    if (_hospedes < 1) {
      return 'Informe ao menos um hóspede.';
    }
    return null;
  }

  Future<void> _enviar() async {
    final erro = _validar();
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final reserva = await _service.createBooking(
        imovelId: _p.id,
        modalidade: _modalidade,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guests: _hospedes,
      );

      if (!mounted) return;
      setState(() {
        _resultado = reserva;
        _enviando = false;
      });
    } on ReservationApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.message;
        _enviando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível enviar a solicitação.';
        _enviando = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final sucesso = _resultado != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: Text(sucesso ? 'Solicitação enviada' : 'Solicitar reserva'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !sucesso,
      ),
      body: sucesso ? _buildSucesso(_resultado!) : _buildFormulario(),
      bottomNavigationBar: sucesso ? null : _buildBarraInferior(),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _p.nome,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: _primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _p.local.isEmpty ? 'Local não informado' : _p.local,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${ReservationPricing.formatarMoeda(_p.preco)} ${_p.periodoPreco}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          if (!_p.aceitaReserva) ...[
            const SizedBox(height: 14),
            _aviso('Este imóvel não está disponível para reserva.'),
          ],
          const SizedBox(height: 18),
          _titulo(_mensal ? 'Período (mensal)' : 'Período (diárias)'),
          const SizedBox(height: 10),
          _card(child: _mensal ? _buildPeriodoMensal() : _buildPeriodoDiaria()),
          const SizedBox(height: 18),
          _titulo('Hóspedes'),
          const SizedBox(height: 10),
          _card(
            child: Row(
              children: [
                const Icon(Icons.people_outline, color: _primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Quantidade de hóspedes',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                _stepper(
                  value: _hospedes,
                  onMinus: _hospedes > 1 ? () => _alterarHospedes(-1) : null,
                  onPlus: _hospedes < _maxHospedes
                      ? () => _alterarHospedes(1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _titulo('Resumo da solicitação'),
          const SizedBox(height: 10),
          _card(child: _buildResumo()),
          if (_erro != null) ...[const SizedBox(height: 14), _aviso(_erro!)],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPeriodoDiaria() {
    return InkWell(
      onTap: _escolherPeriodoDiaria,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Expanded(child: _dataColuna('Check-in', _checkIn)),
          Container(width: 1, height: 42, color: Colors.black12),
          Expanded(child: _dataColuna('Check-out', _checkOut)),
        ],
      ),
    );
  }

  Widget _buildPeriodoMensal() {
    return Column(
      children: [
        InkWell(
          onTap: _escolherCheckInMensal,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Expanded(child: _dataColuna('Entrada', _checkIn)),
              Container(width: 1, height: 42, color: Colors.black12),
              Expanded(child: _dataColuna('Saída', _checkOut)),
            ],
          ),
        ),
        const Divider(height: 26),
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: _primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Quantidade de meses',
                style: TextStyle(fontSize: 15),
              ),
            ),
            _stepper(
              value: _meses,
              onMinus: _meses > 1 ? () => _alterarMeses(-1) : null,
              onPlus: _meses < _maxMeses ? () => _alterarMeses(1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumo() {
    final qtd = _unidades;
    final total = _total;

    if (_checkIn == null || _checkOut == null) {
      return const Text(
        'Selecione as datas para calcular o valor estimado.',
        style: TextStyle(color: Colors.black54),
      );
    }

    if (qtd == null) {
      return const Text(
        'Período inválido. Revise as datas selecionadas.',
        style: TextStyle(color: Colors.redAccent),
      );
    }

    final unidade = _mensal
        ? (qtd == 1 ? 'mês' : 'meses')
        : (qtd == 1 ? 'diária' : 'diárias');

    return Column(
      children: [
        _linha('Modalidade', _mensal ? 'Mensal' : 'Diária'),
        _linha('Entrada', ReservationPricing.formatarData(_checkIn)),
        _linha('Saída', ReservationPricing.formatarData(_checkOut)),
        _linha('Duração', '$qtd $unidade'),
        _linha('Hóspedes', '$_hospedes'),
        _linha(
          'Valor ${_mensal ? 'mensal' : 'da diária'}',
          ReservationPricing.formatarMoeda(_p.preco),
        ),
        const Divider(height: 24),
        _linha(
          'Total estimado',
          ReservationPricing.formatarMoeda(total ?? 0),
          destaque: true,
        ),
        const SizedBox(height: 6),
        Text(
          '$qtd × ${ReservationPricing.formatarMoeda(_p.preco)}',
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildBarraInferior() {
    final total = _total;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total estimado',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    total == null
                        ? '—'
                        : ReservationPricing.formatarMoeda(total),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: (_enviando || !_p.aceitaReserva) ? null : _enviar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enviar solicitação'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSucesso(Reservation r) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.check_circle_outline, size: 86, color: Colors.green),
          const SizedBox(height: 14),
          const Text(
            'Solicitação enviada!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aguarde a análise do locador. Você pode acompanhar o status '
            'na aba Reservas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 22),
          _card(
            child: Column(
              children: [
                _linha('Status', r.statusLabel),
                _linha('Imóvel', r.propertyName),
                _linha('Entrada', ReservationPricing.formatarData(r.checkIn)),
                _linha('Saída', ReservationPricing.formatarData(r.checkOut)),
                _linha('Hóspedes', '${r.guests}'),
                const Divider(height: 24),
                _linha(
                  'Total',
                  ReservationPricing.formatarMoeda(r.totalAmount),
                  destaque: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Concluir'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets auxiliares
  // ---------------------------------------------------------------------------
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _titulo(String texto) => Text(
    texto,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
  );

  Widget _dataColuna(String rotulo, DateTime? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            rotulo,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            data == null ? 'Selecionar' : ReservationPricing.formatarData(data),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: data == null ? _primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper({
    required int value,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline),
          color: _primary,
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline),
          color: _primary,
        ),
      ],
    );
  }

  Widget _linha(String rotulo, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              color: Colors.black54,
              fontSize: destaque ? 16 : 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: destaque ? FontWeight.bold : FontWeight.w600,
                fontSize: destaque ? 18 : 14,
                color: destaque ? _primary : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aviso(String mensagem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5A5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: _primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(color: Color(0xFF7A2323)),
            ),
          ),
        ],
      ),
    );
  }
}
