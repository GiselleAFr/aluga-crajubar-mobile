import 'dart:typed_data';

import 'landlord_property_address.dart';

enum LandlordPropertyType {
  house('casa', 'Casa'),
  apartment('apartamento', 'Apartamento'),
  land('terreno', 'Terreno'),
  commercial('comercial', 'Comercial'),
  other('outro', 'Outro');

  const LandlordPropertyType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LandlordPropertyType fromApi(String value) => switch (value) {
    'casa' => house,
    'apartamento' => apartment,
    'terreno' => land,
    'comercial' => commercial,
    'outro' => other,
    _ => throw FormatException('Tipo de imóvel desconhecido: $value'),
  };
}

enum LandlordPropertyPurpose {
  rental('aluguel', 'Aluguel'),
  sale('venda', 'Venda');

  const LandlordPropertyPurpose(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LandlordPropertyPurpose fromApi(String value) => switch (value) {
    'aluguel' => rental,
    'venda' => sale,
    _ => throw FormatException('Finalidade desconhecida: $value'),
  };
}

enum LandlordRentalPeriod {
  daily('diaria', 'Diária'),
  monthly('mensal', 'Mensal');

  const LandlordRentalPeriod(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LandlordRentalPeriod fromApi(String value) => switch (value) {
    'diaria' => daily,
    'mensal' => monthly,
    _ => throw FormatException('Período de locação desconhecido: $value'),
  };
}

enum LandlordPropertyStatus {
  available('available', 'Disponível'),
  rented('rented', 'Locado'),
  unavailable('unavailable', 'Indisponível');

  const LandlordPropertyStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LandlordPropertyStatus fromApi(String value) => switch (value) {
    'available' => available,
    'rented' => rented,
    'unavailable' => unavailable,
    _ => throw FormatException('Status de imóvel desconhecido: $value'),
  };
}

class LandlordPropertyPhoto {
  const LandlordPropertyPhoto.local({
    required this.bytes,
    this.fileName = 'foto.png',
  }) : assert(bytes != null),
       id = null,
       url = null,
       isCover = false;

  const LandlordPropertyPhoto.remote({
    required this.id,
    required this.url,
    this.isCover = false,
  }) : bytes = null,
       fileName = null;

  final int? id;
  final String? url;
  final Uint8List? bytes;
  final String? fileName;
  final bool isCover;

  bool get isLocal => bytes != null;
}

class LandlordPropertyDraft {
  const LandlordPropertyDraft({
    this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.price,
    required this.photos,
    required this.mainPhotoIndex,
    this.type = LandlordPropertyType.other,
    this.purpose = LandlordPropertyPurpose.rental,
    this.rentalPeriod = LandlordRentalPeriod.daily,
    this.status = LandlordPropertyStatus.available,
  });

  final int? id;
  final String name;
  final String description;
  final LandlordPropertyAddress address;
  final double price;
  final List<LandlordPropertyPhoto> photos;
  final int mainPhotoIndex;
  final LandlordPropertyType type;
  final LandlordPropertyPurpose purpose;
  final LandlordRentalPeriod? rentalPeriod;
  final LandlordPropertyStatus status;

  LandlordPropertyPhoto? get mainPhoto =>
      photos.isEmpty ? null : photos[mainPhotoIndex];

  String get location => '${address.neighborhood}, ${address.city}';
}
