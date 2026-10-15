import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.indiceSelecionado,
    required this.onItemSelecionado,
  });

  final int indiceSelecionado;
  final ValueChanged<int> onItemSelecionado;

  static const List<(IconData, String)> _items = [
    (Icons.home_outlined, 'Início'),
    (Icons.search, 'Buscar'),
    (Icons.favorite_border, 'Favoritos'),
    (Icons.calendar_month_outlined, 'Reservas'),
    (Icons.person_outline, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFE5E0DD))),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 57,
        child: Row(
          children: List.generate(_items.length, (index) {
            final selected = indiceSelecionado == index;
            final item = _items[index];
            final color = selected ? const Color(0xFF963333) : Colors.grey;

            return Expanded(
              child: InkWell(
                onTap: () => onItemSelecionado(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$1, size: 21, color: color),
                    const SizedBox(height: 3),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
