import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'login/login/login.dart';
import 'login/recovery/recovery.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuApp());
}

class MeuApp extends StatefulWidget {
  const MeuApp({super.key});

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  final AppLinks appLinks = AppLinks();

  StreamSubscription<Uri>? linkSubscription;

  @override
  void initState() {
    super.initState();

    linkSubscription = appLinks.uriLinkStream.listen(
      _openResetLink,
      onError: (Object error) {
        debugPrint('Erro ao receber deep link: $error');
      },
    );
  }

  void _openResetLink(Uri uri) {
    final bool isResetLink =
        uri.scheme == 'alugacrajubar' &&
        (uri.host == 'reset-password' || uri.path == '/reset-password');

    final String? token = uri.queryParameters['token'];
    final String? email = uri.queryParameters['email'];

    if (!isResetLink || token == null || email == null) {
      return;
    }

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
    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFF8F7F5),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF963333)),
    );

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Aluga Cariri',
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.copyWith(
          displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
          headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
          headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: baseTheme.textTheme.titleSmall?.copyWith(fontSize: 14),
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 16),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 16),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(fontSize: 14),
          labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          labelMedium: baseTheme.textTheme.labelMedium?.copyWith(fontSize: 14),
          labelSmall: baseTheme.textTheme.labelSmall?.copyWith(fontSize: 12),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
