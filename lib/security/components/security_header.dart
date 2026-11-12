import 'package:flutter/material.dart';

import 'security_colors.dart';

/// Barra superior: voltar circular à esquerda e título centralizado.
class SecurityHeader extends StatelessWidget implements PreferredSizeWidget {
  const SecurityHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: SecurityColors.vinho,
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Material(
            color: SecurityColors.fundoVoltar,
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('security-back'),
              onTap: onBack,
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(
                  Icons.arrow_back,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        'Segurança e Login',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
