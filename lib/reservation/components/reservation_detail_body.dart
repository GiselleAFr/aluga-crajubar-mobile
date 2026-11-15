import 'package:flutter/material.dart';

import '../../properties/components/property_info_sections.dart';
import '../../services/reservation_service.dart';
import '../../utils/external_links.dart';
import '../reservation_pricing.dart';
import 'location_map.dart';
import 'reservation_status_chip.dart';

/// Conteúdo completo de uma reserva: resumo, mapa e dados do imóvel.
/// Usado na aba Reservas (hospedagem atual) e na tela de detalhes.
class ReservationDetailBody extends StatelessWidget {
  const ReservationDetailBody({super.key, required this.reservation});

  final Reservation reservation;

  static const _vinho = Color(0xFFA83232);

  String get _endereco {
    final p = reservation.property;
    final local = (p != null && p.local.isNotEmpty)
        ? p.local
        : [
            reservation.neighborhood,
            reservation.city,
          ].whereType<String>().where((e) => e.isNotEmpty).join(', ');

    return [
      p?.endereco ?? reservation.address,
      local,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).join(', ');
  }

  String get _mensagemStatus => switch (reservation.status) {
    'pending' => 'Aguardando a análise do locador. A reserva só vale depois que ele aprovar.',
    'confirmed' => 'Reserva confirmada pelo locador.',
    'rejected' => 'O locador recusou esta solicitação.',
    'cancelled' => 'Esta reserva foi cancelada.',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final p = r.property;
    final endereco = _endereco;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      r.propertyName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ReservationStatusChip(reservation: r),
                ],
              ),
              if (endereco.isNotEmpty) ...[
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: _vinho),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        endereco,
                        style: const TextStyle(color: Colors.grey, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ],
              if (_mensagemStatus.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _mensagemStatus,
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
              const Divider(height: 25),
              _infoRow(
                Icons.calendar_month_outlined,
                'Entrada',
                ReservationPricing.formatarData(r.checkIn),
              ),
              const SizedBox(height: 12),
              _infoRow(
                Icons.event_available_outlined,
                'Saída',
                ReservationPricing.formatarData(r.checkOut),
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.people_outline, 'Hóspedes', '${r.guests}'),
              const SizedBox(height: 12),
              _infoRow(
                Icons.payments_outlined,
                'Total',
                ReservationPricing.formatarMoeda(r.totalAmount),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Localização',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (p != null && p.hasCoordinates) ...[
          LocationMap(latitude: p.latitude!, longitude: p.longitude!),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ExternalLinks.openMaps(context, p.latitude!, p.longitude!),
              icon: const Icon(Icons.directions),
              label: const Text('Ver rota no Google Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _vinho,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: _vinho),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Icon(Icons.location_off_outlined, size: 42, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'A localização deste imóvel ainda não está disponível.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        if (p != null) ...[
          const SizedBox(height: 28),
          PropertyInfoSections(
            property: p,
            mostrarWhatsapp: true,
            mensagemWhatsapp:
                'Olá! Sobre minha reserva em "${r.propertyName}" '
                '(entrada em ${ReservationPricing.formatarData(r.checkIn)}).',
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _vinho, size: 21),
        const SizedBox(width: 9),
        Text('$label:', style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
