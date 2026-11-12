import 'package:flutter/material.dart';

import '../../services/reservation_service.dart';
import '../reservation_pricing.dart';
import 'reservation_status_chip.dart';

/// Item da lista de solicitações/reservas do cliente.
class ReservationCard extends StatelessWidget {
  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
    this.mostrarStatus = true,
  });

  final Reservation reservation;
  final VoidCallback onTap;

  /// Esconde o selo de status (por exemplo, no histórico).
  final bool mostrarStatus;

  @override
  Widget build(BuildContext context) {
    final r = reservation;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8D8D1)),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (mostrarStatus) ...[
                  const SizedBox(width: 8),
                  ReservationStatusChip(reservation: r),
                ],
              ],
            ),
            if (r.city != null && r.city!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                r.city!,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: Color(0xFFA83232),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${ReservationPricing.formatarData(r.checkIn)}  →  '
                    '${ReservationPricing.formatarData(r.checkOut)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 17,
                  color: Color(0xFFA83232),
                ),
                const SizedBox(width: 6),
                Text(
                  '${r.guests} ${r.guests == 1 ? 'hóspede' : 'hóspedes'}',
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                Text(
                  ReservationPricing.formatarMoeda(r.totalAmount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA83232),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
