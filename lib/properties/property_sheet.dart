import 'package:flutter/material.dart';

import '../home/models/property.dart';
import '../reservation/reservation_pricing.dart';
import '../reservation/reservation_request_page.dart';
import 'property_details_page.dart';

/// BottomSheet de resumo do imóvel, compartilhado por Home, Buscar e Favoritos.
/// Leva para os detalhes ou direto para a solicitação de reserva.
void showPropertySheet(BuildContext context, Property p) {
  const primary = Color(0xFFA83232);
  final navigator = Navigator.of(context);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.nome,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(p.local.isEmpty ? 'Local não informado' : p.local),
            const SizedBox(height: 12),
            Text(
              '${ReservationPricing.formatarMoeda(p.preco)} ${p.periodoPreco}',
              style: const TextStyle(
                color: primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!p.aceitaReserva) ...[
              const SizedBox(height: 10),
              const Text(
                'Este imóvel não está disponível para reserva.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      navigator.push(
                        MaterialPageRoute<void>(
                          builder: (_) => PropertyDetailsPage(property: p),
                        ),
                      );
                    },
                    child: const Text('Ver detalhes'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: p.aceitaReserva
                        ? () {
                            Navigator.pop(sheetContext);
                            navigator.push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ReservationRequestPage(property: p),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Solicitar reserva'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
