import 'package:flutter/material.dart';

class ProfileSettingsSection extends StatelessWidget {
  final VoidCallback onInformacoesPessoais,
      onSeguranca,
      onNotificacoes,
      onMetodoPagamento,
      onTornarLocador,
      onAjuda;

  const ProfileSettingsSection({
    super.key,
    required this.onInformacoesPessoais,
    required this.onSeguranca,
    required this.onNotificacoes,
    required this.onMetodoPagamento,
    required this.onTornarLocador,
    required this.onAjuda,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Configurações',
        style: TextStyle(
          color: Color(0xFF963333),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE8D8D1)),
        ),
        child: Column(
          children: [
            _SettingsItem(
              icon: Icons.person_outline,
              titulo: 'Informações Pessoais',
              onTap: onInformacoesPessoais,
            ),
            _SettingsItem(
              icon: Icons.lock_outline,
              titulo: 'Segurança e Login',
              onTap: onSeguranca,
            ),
            _SettingsItem(
              icon: Icons.notifications_none,
              titulo: 'Notificações',
              onTap: onNotificacoes,
            ),
            _SettingsItem(
              icon: Icons.credit_card_outlined,
              titulo: 'Método de Pagamento',
              onTap: onMetodoPagamento,
            ),
            _SettingsItem(
              icon: Icons.home_work_outlined,
              titulo: 'Tornar-se um Locador',
              onTap: onTornarLocador,
            ),
            _SettingsItem(
              icon: Icons.help_outline,
              titulo: 'Ajuda e Suporte',
              onTap: onAjuda,
              ultimo: true,
            ),
          ],
        ),
      ),
    ],
  );
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final VoidCallback onTap;
  final bool ultimo;

  const _SettingsItem({
    required this.icon,
    required this.titulo,
    required this.onTap,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: ultimo
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFEFE5E0))),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF963333), size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD9A18B), size: 18),
        ],
      ),
    ),
  );
}
