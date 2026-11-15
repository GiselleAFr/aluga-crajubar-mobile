import 'package:flutter/material.dart';

import '../responsive_content.dart';
import '../utils/external_links.dart';
import 'faq_data.dart';

/// Ajuda e suporte: perguntas frequentes (com busca) e contato por e-mail.
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const _vinho = Color(0xFFA83232);
  static const _borda = Color(0xFFE8D8D1);

  final TextEditingController _busca = TextEditingController();
  String _termo = '';
  String? _abertaId;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  /// Minúsculas e sem acentos, para a busca ignorar maiúsculas e acentuação.
  static String _normalizar(String texto) {
    const com = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const sem = 'aaaaaeeeeiiiiooooouuuuc';
    var resultado = texto.toLowerCase();
    for (var i = 0; i < com.length; i++) {
      resultado = resultado.replaceAll(com[i], sem[i]);
    }
    return resultado;
  }

  List<FaqItem> get _filtradas {
    final palavras = _normalizar(_termo)
        .split(RegExp(r'\s+'))
        .where((palavra) => palavra.isNotEmpty)
        .toList();

    if (palavras.isEmpty) return faqItens;

    return faqItens.where((item) {
      final texto = _normalizar('${item.pergunta} ${item.resposta}');
      return palavras.every((palavra) => texto.contains(palavra));
    }).toList();
  }

  void _alternar(String id) {
    setState(() => _abertaId = _abertaId == id ? null : id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Ajuda e suporte'),
        backgroundColor: _vinho,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ResponsiveContent(
          maxWidth: 800,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildIntro(),
              const SizedBox(height: 16),
              _buildCampoBusca(),
              ..._buildSecoes(),
              const SizedBox(height: 28),
              _buildContato(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Como podemos ajudar?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Veja as respostas para as dúvidas mais comuns ou fale com a nossa '
          'equipe.',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: Color(0xFF8A5A00)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lembre-se: a reserva só vale depois que o locador aprovar '
                  'a sua solicitação.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF6B4A00),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampoBusca() {
    return TextField(
      controller: _busca,
      textInputAction: TextInputAction.search,
      onChanged: (valor) => setState(() => _termo = valor),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar nas perguntas',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: _vinho, size: 20),
        suffixIcon: _termo.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpar busca',
                icon: const Icon(Icons.close, size: 18),
                color: Colors.grey,
                onPressed: () {
                  _busca.clear();
                  setState(() => _termo = '');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _vinho),
        ),
      ),
    );
  }

  List<Widget> _buildSecoes() {
    final itens = _filtradas;

    if (itens.isEmpty) {
      return [
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borda),
          ),
          child: const Column(
            children: [
              Icon(Icons.search_off, size: 42, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Não encontramos perguntas com esse termo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Tente outras palavras ou fale com a nossa equipe por '
                'e-mail, logo abaixo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),
            ],
          ),
        ),
      ];
    }

    final widgets = <Widget>[];

    for (final categoria in faqCategorias) {
      final daCategoria = itens
          .where((item) => item.categoria == categoria)
          .toList();
      if (daCategoria.isEmpty) continue;

      widgets
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 24, 0, 10),
            child: Text(
              categoria,
              style: const TextStyle(
                color: _vinho,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
        ..add(_buildCartao(daCategoria));
    }

    return widgets;
  }

  Widget _buildCartao(List<FaqItem> itens) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borda),
      ),
      child: Column(
        children: [
          for (var i = 0; i < itens.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEFE5E0)),
            _FaqTile(
              item: itens[i],
              aberta: _abertaId == itens[i].id,
              onToggle: () => _alternar(itens[i].id),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContato() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6E3DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mail_outline, color: _vinho),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Ainda precisa de ajuda?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Caso ainda tenha alguma dúvida ou precise de um suporte mais '
            'personalizado, fale com nossa equipe por e-mail:',
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const SelectableText(
            supportEmail,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _vinho,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ExternalLinks.openEmail(
                    context,
                    supportEmail,
                    subject: 'Dúvida sobre o AlugaCrajubar',
                    body: 'Olá, equipe do AlugaCrajubar!\n\nPreciso de ajuda com: ',
                  ),
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Enviar e-mail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vinho,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExternalLinks.copy(
                    context,
                    supportEmail,
                    confirmacao: 'E-mail copiado.',
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copiar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _vinho,
                    side: const BorderSide(color: _vinho),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pergunta que abre e fecha mostrando a resposta.
class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.aberta,
    required this.onToggle,
  });

  final FaqItem item;
  final bool aberta;
  final VoidCallback onToggle;

  static const _vinho = Color(0xFFA83232);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      expanded: aberta,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.pergunta,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: aberta ? FontWeight.w700 : FontWeight.w600,
                        color: aberta ? _vinho : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: aberta ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: _vinho),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: aberta
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10, right: 8),
                        child: Text(
                          item.resposta,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
