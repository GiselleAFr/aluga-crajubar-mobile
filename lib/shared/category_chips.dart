import 'package:flutter/material.dart';

/// Filtros em formato de chips, em uma única linha que rola para o lado.
///
/// - Um esmaecido na borda indica que há mais opções fora da tela.
/// - Ao escolher um chip, a linha rola sozinha para mostrá-lo no centro.
/// - Se tudo couber na largura, não há rolagem nem esmaecido.
class CategoryChips extends StatefulWidget {
  const CategoryChips({
    super.key,
    required this.categorias,
    required this.selecionada,
    required this.onSelecionar,
  });

  final List<String> categorias;
  final int selecionada;
  final ValueChanged<int> onSelecionar;

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  static const _vinho = Color(0xFF963333);
  static const _borda = Color(0xFFE8D2C7);

  final ScrollController _controller = ScrollController();
  late List<GlobalKey> _chaves;
  bool _fadeEsquerda = false;
  bool _fadeDireita = false;

  List<GlobalKey> _novasChaves() =>
      List.generate(widget.categorias.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _chaves = _novasChaves();
    _controller.addListener(_atualizarFade);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _atualizarFade();
      _centralizarSelecionada(animar: false);
    });
  }

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categorias.length != widget.categorias.length) {
      _chaves = _novasChaves();
    }
    final mudouSelecao = oldWidget.selecionada != widget.selecionada;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _atualizarFade();
      if (mudouSelecao) _centralizarSelecionada();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_atualizarFade);
    _controller.dispose();
    super.dispose();
  }

  /// Mostra o esmaecido só do lado em que ainda há conteúdo para rolar.
  void _atualizarFade() {
    if (!mounted || !_controller.hasClients) return;
    final posicao = _controller.position;
    final esquerda = posicao.extentBefore > 1;
    final direita = posicao.extentAfter > 1;

    if (esquerda != _fadeEsquerda || direita != _fadeDireita) {
      setState(() {
        _fadeEsquerda = esquerda;
        _fadeDireita = direita;
      });
    }
  }

  /// Rola só a linha de chips (não mexe na rolagem vertical da página).
  void _centralizarSelecionada({bool animar = true}) {
    if (!mounted || !_controller.hasClients) return;
    final indice = widget.selecionada;
    if (indice < 0 || indice >= _chaves.length) return;

    final chip = _chaves[indice].currentContext?.findRenderObject();
    final area = context.findRenderObject();
    if (chip is! RenderBox || area is! RenderBox) return;
    if (!chip.attached || !area.attached) return;

    final esquerdaDoChip = chip.localToGlobal(Offset.zero, ancestor: area).dx;
    final centroDoChip = esquerdaDoChip + chip.size.width / 2;
    final posicao = _controller.position;
    final alvo = (posicao.pixels + centroDoChip - area.size.width / 2).clamp(
      posicao.minScrollExtent,
      posicao.maxScrollExtent,
    );

    if (animar) {
      _controller.animateTo(
        alvo,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(alvo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = widget.categorias.length - 1;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          _fadeEsquerda ? Colors.transparent : Colors.black,
          Colors.black,
          Colors.black,
          _fadeDireita ? Colors.transparent : Colors.black,
        ],
        stops: const [0.0, 0.08, 0.92, 1.0],
      ).createShader(bounds),
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i <= ultimo; i++)
              Padding(
                padding: EdgeInsets.only(right: i == ultimo ? 0 : 8),
                child: KeyedSubtree(key: _chaves[i], child: _buildChip(i)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(int index) {
    final ativo = index == widget.selecionada;

    return Semantics(
      button: true,
      selected: ativo,
      child: Material(
        color: ativo ? _vinho : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: StadiumBorder(side: BorderSide(color: ativo ? _vinho : _borda)),
        child: InkWell(
          onTap: () => widget.onSelecionar(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              widget.categorias[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ativo ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
