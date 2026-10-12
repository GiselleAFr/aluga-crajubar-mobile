class Property {
  final String nome, local, categoria, imagem;
  final int preco;
  final double nota;
  bool favorito;

  Property({
    required this.nome,
    required this.local,
    required this.categoria,
    required this.imagem,
    required this.preco,
    required this.nota,
    this.favorito = false,
  });
}
