import 'package:flutter/material.dart';

/// Faixa compacta "Como funciona" com 3 passos e atalho para a ajuda.
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key, required this.onAjudaPressed});

  final VoidCallback onAjudaPressed;

  static const _vinho = Color(0xFF963333);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D8D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Como funciona',
                  style: TextStyle(
                    color: _vinho,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAjudaPressed,
                icon: const Icon(Icons.help_outline, size: 16),
                label: const Text('Ajuda e suporte'),
                style: TextButton.styleFrom(
                  foregroundColor: _vinho,
                  textStyle: const TextStyle(fontSize: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Step(
                  icone: Icons.search,
                  titulo: 'Escolha',
                  texto: 'Encontre o imóvel ideal',
                ),
              ),
              Expanded(
                child: _Step(
                  icone: Icons.event_available_outlined,
                  titulo: 'Solicite',
                  texto: 'Informe datas e hóspedes',
                ),
              ),
              Expanded(
                child: _Step(
                  icone: Icons.verified_outlined,
                  titulo: 'Aguarde',
                  texto: 'O locador analisa e aprova',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF8A5A00)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A reserva só vale depois que o locador aprovar a sua '
                    'solicitação.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF6B4A00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFF6E3DE),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 20, color: const Color(0xFF963333)),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            texto,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.black54,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}