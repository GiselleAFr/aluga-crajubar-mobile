import 'package:flutter/material.dart';
import '../../home/models/property.dart';
import 'imovel_card.dart';

class SecaoImoveis extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Property> imoveis;
  final VoidCallback onVerTodos;
  final ValueChanged<Property> onReservar;
  final ValueChanged<Property> onImovelPressed;

  const SecaoImoveis({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.imoveis,
    required this.onVerTodos,
    required this.onReservar,
    required this.onImovelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFFA83232),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: onVerTodos,
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFFA83232),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitulo,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 9),
          if (imoveis.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Nenhum imóvel encontrado.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 250)
                    .floor()
                    .clamp(1, 4)
                    .toInt();

                const spacing = 12.0;
                final largura =
                    (constraints.maxWidth - spacing * (columns - 1)) /
                    columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: imoveis.map((imovel) {
                    return SizedBox(
                      width: largura,
                      child: ImovelCard(
                        imovel: imovel.toSearchCardData(),
                        onReservar: () => onReservar(imovel),
                        onTap: () => onImovelPressed(imovel),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
