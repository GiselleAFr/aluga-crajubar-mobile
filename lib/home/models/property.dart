class Property {
  final int id;
  final String nome, local, categoria, tipo, unidadePreco;
  final String? imagem;
  final double preco;
  final double? nota;

  final String? descricao;
  final String? endereco;
  final int quartos;
  final int banheiros;
  final double? area;
  bool favorito;


  Property({
    required this.id,
    required this.nome,
    required this.local,
    required this.categoria,
    required this.tipo,
    required this.unidadePreco,
    required this.imagem,
    required this.preco,
    required this.nota,
    required this.descricao,

    required this.endereco,
    required this.quartos,
    required this.banheiros,
    required this.area,
    this.favorito = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String? ?? 'outro';
    return Property(
      id: (json['id'] as num).toInt(),
      nome: json['titulo'] as String? ?? 'Imóvel',
      local: [
        json['bairro'],
        json['cidade'],
      ].whereType<String>().where((value) => value.isNotEmpty).join(', '),
      categoria: switch (tipo) {
        'casa' => 'Casas',
        'apartamento' => 'Apartamentos',
        'quarto' || 'pousada' || 'kitnet' => 'Quartos e pousadas',
        'comercial' => 'Comerciais',
        'terreno' => 'Terrenos',
        _ => 'Outros',
      },
      tipo: tipo,
      unidadePreco:
        json['unidade_preco'] as String? ??
        (json['finalidade'] == 'diaria' ? 'dia' : 'mes'),
      imagem: json['imagem'] as String?,
      preco: double.tryParse(json['preco']?.toString() ?? '') ?? 0,
      nota: json['avaliacao'] == null
          ? null
          : double.tryParse(json['avaliacao'].toString()),
      
      descricao: json['descricao'] as String?,
      endereco: json['endereco'] as String?,
      quartos: (json['quartos'] as num?)?.toInt() ?? 0,
      banheiros: (json['banheiros'] as num?)?.toInt() ?? 0,
      area: json['area'] == null
          ? null
          : double.tryParse(json['area'].toString()),
    );
  }

  Map<String, dynamic> toSearchCardData() => {
    'nome': nome,
    'local': local,
    'preco': preco,
    'unidade_preco': unidadePreco,
    'avaliacao': nota,
    'imagem': imagem ?? '',
    'categoria': categoria,
    'periodo_preco': periodoPreco,
  };

  String get periodoPreco => switch (unidadePreco) {
    'dia' => '/diária',
    'mes' => '/mês',
    'total' => 'total',
    _ => '/$unidadePreco',
  };
}
