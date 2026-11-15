import 'package:flutter/material.dart';

import '../responsive_content.dart';

/// Cabeçalho padrão do app (Home, Buscar, Favoritos, Reservas).
/// Título, subtítulo e avatar; opcionalmente um [child] abaixo dos textos
/// (por exemplo, o campo de busca).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.child,
  });

  final String titulo;
  final String subtitulo;
  final Widget? child;

  static const _vinho = Color(0xFFA83232);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, 25, 22, child == null ? 28 : 22),
      decoration: const BoxDecoration(
        color: _vinho,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: ResponsiveContent(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: const CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: _vinho, size: 24),
                  ),
                ),
              ],
            ),
            if (child != null) ...[const SizedBox(height: 16), child!],
          ],
        ),
      ),
    );
  }
}
