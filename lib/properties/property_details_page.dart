import 'package:flutter/material.dart';

import '../home/models/property.dart';
import '../reservation/reservation_request_page.dart';
import '../utils/external_links.dart';
import 'components/property_info_sections.dart';

class PropertyDetailsPage extends StatelessWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  static const _primary = Color(0xFFA83232);

  void _solicitarReserva(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationRequestPage(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enderecoCompleto = [
      property.endereco,
      property.local,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).join(', ');

    final temTelefone = ExternalLinks.hasPhone(property.locadorTelefone);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Detalhes do imóvel'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: property.imagem == null || property.imagem!.isEmpty
                  ? Container(
                      color: const Color(0xFFE5DAD3),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: _primary,
                      ),
                    )
                  : Image.network(
                      property.imagem!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFE5DAD3),
                        child: const Center(
                          child: Icon(
                            Icons.home_work_outlined,
                            size: 80,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.nome,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: _primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          enderecoCompleto.isEmpty
                              ? 'Endereço não informado'
                              : enderecoCompleto,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PropertyInfoSections(property: property),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!property.aceitaReserva)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Este imóvel não está disponível para reserva.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: property.aceitaReserva
                      ? () => _solicitarReserva(context)
                      : null,
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Solicitar reserva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: temTelefone
                      ? () => ExternalLinks.openWhatsapp(
                          context,
                          property.locadorTelefone,
                          message:
                              'Olá! Vi o imóvel "${property.nome}" no '
                              'AlugaCrajubar e gostaria de mais informações.',
                        )
                      : null,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Conversar pelo WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E8E4E),
                    side: BorderSide(
                      color: temTelefone
                          ? const Color(0xFF1E8E4E)
                          : Colors.black12,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
