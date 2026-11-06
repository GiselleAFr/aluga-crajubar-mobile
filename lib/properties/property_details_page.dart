import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/models/property.dart';
import '../reservation/reservation_pricing.dart';
import '../reservation/reservation_request_page.dart';

class PropertyDetailsPage extends StatelessWidget {
  final Property property;

  const PropertyDetailsPage({super.key, required this.property});

  static const _primary = Color(0xFF963333);

  /// Normaliza o telefone para o formato do wa.me (DDI + DDD + número).
  String? _numeroWhatsapp(String? telefone) {
    final digitos = (telefone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return null;
    if (digitos.startsWith('55') && digitos.length >= 12) return digitos;
    if (digitos.length == 10 || digitos.length == 11) return '55$digitos';
    return digitos;
  }

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final numero = _numeroWhatsapp(property.locadorTelefone);
    final messenger = ScaffoldMessenger.of(context);

    if (numero == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('O locador não informou um telefone.')),
      );
      return;
    }

    final mensagem =
        'Olá! Vi o imóvel "${property.nome}" no AlugaCrajubar e '
        'gostaria de mais informações.';
    final uri = Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}',
    );

    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

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

    final temTelefone = _numeroWhatsapp(property.locadorTelefone) != null;

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
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: ReservationPricing.formatarMoeda(
                            property.preco,
                          ),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                        TextSpan(
                          text: ' ${property.periodoPreco}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Características do imóvel',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.bed_outlined,
                          label: 'Quartos',
                          value: '${property.quartos}',
                        ),
                      ),
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.bathtub_outlined,
                          label: 'Banheiros',
                          value: '${property.banheiros}',
                        ),
                      ),
                      Expanded(
                        child: _FeatureItem(
                          icon: Icons.square_foot,
                          label: 'Área',
                          value: property.area == null
                              ? 'Não informada'
                              : '${property.area!.toStringAsFixed(2).replaceAll('.', ',')} m²',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Sobre o imóvel',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    property.descricao?.trim().isNotEmpty == true
                        ? property.descricao!
                        : 'Nenhuma descrição foi cadastrada para este imóvel.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Locador',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, color: _primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                property.locadorNome?.trim().isNotEmpty == true
                                    ? property.locadorNome!
                                    : 'Locador não informado',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, color: _primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                temTelefone
                                    ? property.locadorTelefone!
                                    : 'Telefone não informado',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  onPressed: temTelefone ? () => _abrirWhatsApp(context) : null,
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 27, color: const Color(0xFF963333)),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}