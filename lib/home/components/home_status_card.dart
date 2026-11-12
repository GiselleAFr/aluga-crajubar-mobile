import 'package:flutter/material.dart';

import '../../reservation/reservation_pricing.dart';
import '../home_status.dart';

/// Card de status: hospedagem atual, reserva aguardando ou
/// solicitações pendentes (locador).
class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({super.key, required this.status, required this.onTap});

  final HomeStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = status.reservation;
    final n = status.count;

    final (
      IconData icone,
      Color fundo,
      Color cor,
      String titulo,
      String subtitulo,
      String acao,
    ) = switch (status.type) {
      HomeStatusType.activeStay => (
        Icons.home_outlined,
        const Color(0xFFE3F4E8),
        const Color(0xFF1E7A3E),
        'Você está hospedado agora',
        '${r?.propertyName ?? 'Sua hospedagem'} · até '
            '${ReservationPricing.formatarData(r?.checkOut)}',
        'Ver no mapa e detalhes',
      ),
      HomeStatusType.awaitingApproval => (
        Icons.hourglass_top_outlined,
        const Color(0xFFFFF3D6),
        const Color(0xFF8A5A00),
        n == 1
            ? 'Reserva aguardando resposta'
            : '$n reservas aguardando resposta',
        n == 1
            ? '${r?.propertyName ?? 'Sua solicitação'} · o locador ainda vai analisar.'
            : 'Os locadores ainda vão analisar suas solicitações.',
        'Ver minhas reservas',
      ),
      HomeStatusType.landlordPending => (
        Icons.inbox_outlined,
        const Color(0xFFF6E3DE),
        const Color(0xFFA83232),
        n == 1 ? '1 solicitação pendente' : '$n solicitações pendentes',
        'Responda aos hóspedes interessados nos seus imóveis.',
        'Ver solicitações',
      ),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8D8D1)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
                child: Icon(icone, color: cor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      acao,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD9A18B)),
            ],
          ),
        ),
      ),
    );
  }
}
