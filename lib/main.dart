
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
        (uri.host == 'reset-password' ||
            uri.path == '/reset-password');

    final String? token = uri.queryParameters['token'];
    final String? email = uri.queryParameters['email'];

    if (!isResetLink || token == null || email == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appNavigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => RecoveryPage(
            resetEmail: email,
            resetToken: token,
          ),
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
      title: 'Aluga Cariri',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF963333),
        ),
      ),
      home: const LoginPage(),
    );
  }
}