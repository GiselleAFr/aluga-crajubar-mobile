import 'package:flutter/material.dart';

import '../../utils/external_links.dart';
import '../../utils/formatters.dart';

/// Resumo do usuário: avatar com iniciais, papel, contatos (com copiar)
/// e números de hospedagens, pendentes e favoritos.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.nomeUsuario,
    required this.email,
    required this.telefone,
    required this.favoritos,
    this.papel,
    this.hospedagens,
    this.pendentes,
    this.onTap,
  });

  final String nomeUsuario;
  final String email;
  final String telefone;
  final int favoritos;

  /// client, landlord ou admin (null esconde o selo).
  final String? papel;

  /// null mostra "—" (carregando ou indisponível).
  final int? hospedagens;
  final int? pendentes;

  /// Se null, o card não é clicável.
  final VoidCallback? onTap;

  static const _vinho = Color(0xFFA83232);
  static const _borda = Color(0xFFE8D8D1);

  String get _iniciais {
    final partes = nomeUsuario
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  String? get _papelRotulo => switch (papel) {
    'landlord' => 'Locador',
    'admin' => 'Administrador',
    'client' => 'Cliente',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final rotulo = _papelRotulo;

    final conteudo = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borda),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _vinho, width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFF0D9D2),
                  child: Text(
                    _iniciais,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: _vinho,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeUsuario,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (rotulo != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E3DE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rotulo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _vinho,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const _Separador(),
          _ContatoLinha(
            icone: Icons.email_outlined,
            texto: email.isEmpty ? 'E-mail não informado' : email,
            onCopiar: email.isEmpty
                ? null
                : () => ExternalLinks.copy(
                    context,
                    email,
                    confirmacao: 'E-mail copiado.',
                  ),
          ),
          _ContatoLinha(
            icone: Icons.phone_outlined,
            texto: telefone.isEmpty
                ? 'Telefone não informado'
                : formatarTelefone(telefone),
            onCopiar: telefone.isEmpty
                ? null
                : () => ExternalLinks.copy(
                    context,
                    telefone,
                    confirmacao: 'Telefone copiado.',
                  ),
          ),
          const _Separador(),
          Row(
            children: [
              Expanded(
                child: _Estatistica(
                  valor: hospedagens?.toString() ?? '—',
                  rotulo: 'Hospedagens',
                ),
              ),
              Container(width: 1, height: 30, color: _borda),
              Expanded(
                child: _Estatistica(
                  valor: pendentes?.toString() ?? '—',
                  rotulo: 'Pendentes',
                ),
              ),
              Container(width: 1, height: 30, color: _borda),
              Expanded(
                child: _Estatistica(valor: '$favoritos', rotulo: 'Favoritos'),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return conteudo;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: conteudo,
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: Color(0xFFE8D8D1)),
  );
}

class _ContatoLinha extends StatelessWidget {
  const _ContatoLinha({
    required this.icone,
    required this.texto,
    required this.onCopiar,
  });

  final IconData icone;
  final String texto;
  final VoidCallback? onCopiar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Icon(icone, color: const Color(0xFFA83232), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
          ),
          if (onCopiar != null)
            IconButton(
              tooltip: 'Copiar',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              color: Colors.black45,
              icon: const Icon(Icons.copy_outlined),
              onPressed: onCopiar,
            ),
        ],
      ),
    );
  }
}

class _Estatistica extends StatelessWidget {
  const _Estatistica({required this.valor, required this.rotulo});

  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFFA83232),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          rotulo,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
