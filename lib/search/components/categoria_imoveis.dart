import 'package:flutter/material.dart';

class CategoriaImoveis extends StatelessWidget {
  final List<String> categorias;
  final int selecionada;
  final ValueChanged<int> onSelecionar;

  const CategoriaImoveis({
    super.key,
    required this.categorias,
    required this.selecionada,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(categorias.length, (index) {
              final ativo = index == selecionada;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onSelecionar(index),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: ativo ? const Color(0xFFA83232) : Colors.white,
                      border: Border.all(
                        color: ativo
                            ? const Color(0xFFA83232)
                            : const Color(0xFFE8D2C7),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categorias[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ativo ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
