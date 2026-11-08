import '../../favorites/favorites_store.dart';

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

  /// Estado de favorito compartilhado: todas as cópias do mesmo imóvel
  /// (Home, Buscar, Favoritos) enxergam o mesmo valor.
  bool get favorito => FavoritesStore.instance.isFavorite(id);
  set favorito(bool value) => FavoritesStore.instance.setFavorite(this, value);

  /// 'aluguel' ou 'venda'.
  final String? finalidade;

  /// 'diaria' ou 'mensal' (apenas para aluguel).
  final String? periodoLocacao;

  final String? locadorNome;
  final String? locadorTelefone;

  final double? latitude;
  final double? longitude;

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
    bool favorito = false,
    this.finalidade,
    this.periodoLocacao,
    this.locadorNome,
    this.locadorTelefone,
    this.latitude,
    this.longitude,
  }) {
    if (favorito) this.favorito = true;
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'] as String? ?? 'outro';

    // A API envia o dono do imóvel em "proprietario" (id, name, phone).
    final proprietarioRaw = json['proprietario'] ?? json['locador'];
    final proprietario = proprietarioRaw is Map<String, dynamic>
        ? proprietarioRaw
        : null;

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
          (json['periodo_locacao'] == 'diaria' ? 'dia' : 'mes'),
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
      finalidade: json['finalidade'] as String?,
      periodoLocacao: json['periodo_locacao'] as String?,
      locadorNome: proprietario?['name'] as String?,
      locadorTelefone: (proprietario?['phone'] ?? proprietario?['telefone'])
          ?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
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

  /// O imóvel pode receber solicitação de reserva?
  bool get aceitaReserva =>
      finalidade == 'aluguel' &&
      (periodoLocacao == 'diaria' || periodoLocacao == 'mensal') &&
      preco > 0;

  bool get isMensal => periodoLocacao == 'mensal';

  bool get hasCoordinates => latitude != null && longitude != null;
}
