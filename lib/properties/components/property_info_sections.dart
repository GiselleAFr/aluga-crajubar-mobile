import 'package:flutter/material.dart';

import '../../home/models/property.dart';
import '../../reservation/reservation_pricing.dart';
import '../../utils/external_links.dart';

/// Preço, características, descrição e dados do locador.
/// Usado na tela do imóvel e na tela de reservas (abaixo do mapa).
class PropertyInfoSections extends StatelessWidget {
  const PropertyInfoSections({
    super.key,
    required this.property,
    this.mostrarWhatsapp = false,
    this.mensagemWhatsapp,
  });

  final Property property;

  /// Mostra o botão de WhatsApp dentro do card do locador.
  final bool mostrarWhatsapp;
  final String? mensagemWhatsapp;

  static const _primary = Color(0xFF963333);

  @override
  Widget build(BuildContext context) {
    final telefone = property.locadorTelefone?.trim() ?? '';
    final temTelefone = ExternalLinks.hasPhone(telefone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: ReservationPricing.formatarMoeda(property.preco),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              TextSpan(
                text: ' ${property.periodoPreco}',
                style: const TextStyle(fontSize: 15, color: Colors.black54),
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
          style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, color: _primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      temTelefone ? telefone : 'Telefone não informado',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  if (temTelefone)
                    IconButton(
                      tooltip: 'Copiar número',
                      icon: const Icon(Icons.copy_outlined, size: 20),
                      color: _primary,
                      onPressed: () => ExternalLinks.copy(
                        context,
                        telefone,
                        confirmacao: 'Número copiado.',
                      ),
                    ),
                ],
              ),
              if (mostrarWhatsapp && temTelefone) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ExternalLinks.openWhatsapp(
                      context,
                      telefone,
                      message:
                          mensagemWhatsapp ??
                          'Olá! Vi o imóvel "${property.nome}" no '
                              'AlugaCrajubar e gostaria de mais informações.',
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Conversar pelo WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E8E4E),
                      side: const BorderSide(color: Color(0xFF1E8E4E)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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