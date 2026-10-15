
import 'package:flutter/material.dart';
import 'imovel_card.dart';

class SecaoImoveis extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<Map<String, dynamic>> imoveis;
  final VoidCallback onVerTodos;
  final ValueChanged<Map<String, dynamic>> onReservar;

  const SecaoImoveis({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.imoveis,
    required this.onVerTodos,
    required this.onReservar,
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
                    fontSize: 11,
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
                    fontSize: 9,
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
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 9),

          if (imoveis.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Nenhum imóvel encontrado.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final largura = (constraints.maxWidth - 10) / 2;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: imoveis.map((imovel) {
                    return SizedBox(
                      width: largura,
                      child: ImovelCard(
                        imovel: imovel,
                        onReservar: () => onReservar(imovel),
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
