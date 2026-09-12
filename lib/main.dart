import 'package:flutter/material.dart';
import 'login/login/login.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu App',

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const LoginPage(),
    );
  }
}