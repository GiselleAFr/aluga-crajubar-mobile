import 'package:flutter/material.dart';

import '../../shared/page_header.dart';

/// Header do perfil: mesmo formato da Home, sem o campo de busca.
class ProfileHeader extends StatelessWidget {
  final String nomeUsuario;
  final String membroDesde;

  const ProfileHeader({
    super.key,
    required this.nomeUsuario,
    this.membroDesde = 'Membro desde —',
  });

  @override
  Widget build(BuildContext context) =>
      PageHeader(titulo: 'Olá, $nomeUsuario!', subtitulo: membroDesde);
}
