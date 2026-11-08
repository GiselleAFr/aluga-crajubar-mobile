import 'package:flutter/material.dart';

import '../../reservation/components/reservation_card.dart';
import '../../reservation/reservation_details_page.dart';
import '../../responsive_content.dart';
import '../../services/reservation_service.dart';

/// Todas as hospedagens concluídas do usuário.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.estadias});

  final List<Reservation> estadias;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Histórico de hospedagens'),
        backgroundColor: const Color(0xFF963333),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ResponsiveContent(
        maxWidth: 800,
        child: ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: estadias.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => ReservationCard(
            reservation: estadias[index],
            mostrarStatus: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ReservationDetailsPage(reservation: estadias[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}