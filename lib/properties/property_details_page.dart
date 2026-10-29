import 'package:flutter/material.dart';
import '../home/models/property.dart';

class PropertyDetailsPage extends StatelessWidget {
  final Property property;

  const PropertyDetailsPage({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF963333);

    final enderecoCompleto = [
      property.endereco,
      property.local,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Detalhes do imóvel'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: property.imagem == null ||
                      property.imagem!.isEmpty
                  ? Container(
                      color: const Color(0xFFE5DAD3),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: primaryColor,
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
                            color: primaryColor,
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
                      const Icon(
                        Icons.location_on_outlined,
                        color: primaryColor,
                      ),
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

                  Text(
                    'R\$ ${property.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Características do imóvel',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
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
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
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
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}