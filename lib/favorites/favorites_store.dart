import 'package:flutter/foundation.dart';

import '../home/models/property.dart';

/// Fonte única dos favoritos do app (Home, Buscar e Favoritos).
///
/// Guarda os imóveis favoritados na ordem em que foram adicionados e avisa
/// as telas quando algo muda.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();

  static final FavoritesStore instance = FavoritesStore._();

  final Map<int, Property> _items = <int, Property>{};

  /// Favoritos na ordem em que foram adicionados (o mais antigo primeiro).
  List<Property> get items => List<Property>.unmodifiable(_items.values);

  int get count => _items.length;

  bool isFavorite(int id) => _items.containsKey(id);

  void setFavorite(Property property, bool value) {
    bool mudou;
    if (value) {
      mudou = !_items.containsKey(property.id);
      if (mudou) _items[property.id] = property;
    } else {
      mudou = _items.remove(property.id) != null;
    }
    if (mudou) notifyListeners();
  }

  void toggle(Property property) =>
      setFavorite(property, !isFavorite(property.id));

  /// Use ao sair da conta, para não vazar favoritos para o próximo usuário.
  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
