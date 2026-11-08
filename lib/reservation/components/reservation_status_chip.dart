import 'package:flutter/material.dart';

import '../../services/reservation_service.dart';

class ReservationStatusChip extends StatelessWidget {
  const ReservationStatusChip({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final (fundo, texto) = switch (reservation.status) {
      'pending' => (const Color(0xFFFFF3D6), const Color(0xFF8A5A00)),
      'confirmed' => (const Color(0xFFE3F4E8), const Color(0xFF1E7A3E)),
      'rejected' => (const Color(0xFFFDE6E6), const Color(0xFFA32727)),
      _ => (const Color(0xFFEDEDED), const Color(0xFF616161)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        reservation.statusLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
      ),
    );
  }
}