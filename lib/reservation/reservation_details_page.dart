import 'package:flutter/material.dart';

import '../services/reservation_service.dart';
import 'components/reservation_detail_body.dart';

/// Detalhes de uma solicitação/reserva. Faz pop(true) se algo mudou
/// (por exemplo, após cancelar), para a lista recarregar.
class ReservationDetailsPage extends StatefulWidget {
  const ReservationDetailsPage({super.key, required this.reservation});

  final Reservation reservation;

  @override
  State<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  static const _vinho = Color(0xFFA83232);

  final ReservationService _service = ReservationService();
  bool _cancelando = false;

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  Future<void> _cancelar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar reserva?'),
        content: const Text(
          'Essa ação não pode ser desfeita. O período voltará a ficar '
          'disponível para outras pessoas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Cancelar reserva',
              style: TextStyle(color: _vinho),
            ),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _cancelando = true);

    try {
      await _service.cancelBooking(widget.reservation.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Reserva cancelada com sucesso.')),
      );
      navigator.pop(true);
    } on ReservationApiException catch (e) {
      if (!mounted) return;
      setState(() => _cancelando = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _cancelando = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível cancelar a reserva.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Detalhes da reserva'),
        backgroundColor: _vinho,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: ReservationDetailBody(reservation: r),
      ),
      bottomNavigationBar: r.canCancel
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancelando ? null : _cancelar,
                    icon: _cancelando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: Text(
                      r.status == 'pending'
                          ? 'Cancelar solicitação'
                          : 'Cancelar reserva',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _vinho,
                      side: const BorderSide(color: _vinho),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
