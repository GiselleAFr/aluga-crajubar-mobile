import 'package:flutter/material.dart';

import '../../shared/page_header.dart';
import '../../shared/search_field.dart';

/// Header da Home: saudação com o nome do usuário e o campo de busca
/// (atalho para a tela Buscar), no mesmo formato dos demais headers.
class HomeHeader extends StatelessWidget {
  final String nomeUsuario;
  final TextEditingController? controller;
  final ValueChanged<String>? onBuscaAlterada;
  final ValueChanged<String>? onBuscaEnviada;
  final String hintText;
  final bool autofocus;

  const HomeHeader({
    super.key,
    required this.nomeUsuario,
    this.controller,
    this.onBuscaAlterada,
    this.onBuscaEnviada,
    this.hintText = 'Buscar imóveis...',
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) => PageHeader(
    titulo: 'Olá, $nomeUsuario!',
    subtitulo: 'Encontre o imóvel ideal para você',
    child: SearchField(
      controller: controller,
      onChanged: onBuscaAlterada,
      onSubmitted: onBuscaEnviada,
      hintText: hintText,
      autofocus: autofocus,
    ),
  );
}