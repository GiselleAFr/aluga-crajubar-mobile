import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'login/login/login.dart';
import 'login/recovery/recovery.dart';
import 'login/session_page.dart';
import 'services/auth_service.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatefulWidget {
  const MeuApp({super.key});

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  final appLinks = AppLinks();
  StreamSubscription<Uri>? linkSubscription;

  @override
  void initState() {
    super.initState();
    linkSubscription = appLinks.uriLinkStream.listen(_openResetLink);
  }

  void _openResetLink(Uri uri) {
    final isResetLink =
        uri.scheme == 'alugacrajubar' &&
        (uri.host == 'reset-password' || uri.path == '/reset-password');
    final token = uri.queryParameters['token'];
    final email = uri.queryParameters['email'];
    if (!isResetLink || token == null || email == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appNavigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => RecoveryPage(resetEmail: email, resetToken: token),
        ),
      );
    });
  }

  @override
  void dispose() {
    linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Meu App',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final authService = AuthService();
  late Future<AuthUser?> session = _restoreSession();

  Future<AuthUser?> _restoreSession() async {
    if (await authService.accessToken == null) return null;
    try {
      return await authService.currentUser();
    } on AuthException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthUser?>(
      future: session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        return user == null ? const LoginPage() : SessionPage(user: user);
      },
    );
  }
}
