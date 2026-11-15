import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.indiceSelecionado,
    required this.onItemSelecionado,
    this.mostrarLocador = false,
  });

  final int indiceSelecionado;
  final ValueChanged<int> onItemSelecionado;
  final bool mostrarLocador;

  static const List<(int, IconData, String)> _items = [
    (0, Icons.home_outlined, 'Início'),
    (1, Icons.search, 'Buscar'),
    (2, Icons.favorite_border, 'Favoritos'),
    (3, Icons.calendar_month_outlined, 'Reservas'),
    (5, Icons.home_work_outlined, 'Locador'),
    (4, Icons.person_outline, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleItems = _items
        .where((item) => mostrarLocador || item.$1 != 5)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E0DD))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 57,
          child: Row(
            children: [
              for (final item in visibleItems)
                Expanded(
                  child: InkWell(
                    onTap: () => onItemSelecionado(item.$1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.$1 == 5)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 21,
                                color: indiceSelecionado == item.$1
                                    ? const Color(0xFFA83232)
                                    : Colors.grey,
                              ),
                              Positioned(
                                right: -2,
                                bottom: -1,
                                child: Icon(
                                  Icons.lock_outline,
                                  size: 10,
                                  color: indiceSelecionado == item.$1
                                      ? const Color(0xFFA83232)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          )
                        else
                          Icon(
                            item.$2,
                            size: 21,
                            color: indiceSelecionado == item.$1
                                ? const Color(0xFFA83232)
                                : Colors.grey,
                          ),
                        const SizedBox(height: 3),
                        Text(
                          item.$3,
                          style: TextStyle(
                            fontSize: 12,
                            color: indiceSelecionado == item.$1
                                ? const Color(0xFFA83232)
                                : Colors.grey,
                            fontWeight: indiceSelecionado == item.$1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
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
