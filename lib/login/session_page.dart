import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login/login.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.user});

  final AuthUser user;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final authService = AuthService();
  bool encerrandoSessao = false;

  Future<void> _logout() async {
    if (encerrandoSessao) return;
    setState(() => encerrandoSessao = true);
    try {
      await authService.logout();
    } on AuthException {
      // The token is cleared locally even if the API is unavailable.
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aluga Crajubar')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 72),
              const SizedBox(height: 16),
              Text(
                'Olá, ${widget.user.name}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(widget.user.email),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: encerrandoSessao ? null : _logout,
                icon: encerrandoSessao
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
