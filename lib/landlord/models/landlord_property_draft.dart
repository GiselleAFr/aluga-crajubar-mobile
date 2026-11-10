import 'dart:typed_data';

import 'landlord_property_address.dart';

enum LandlordPropertyStatus {
  available('Disponível'),
  rented('Locado'),
  unavailable('Indisponível');

  const LandlordPropertyStatus(this.label);

  final String label;
}

class LandlordPropertyDraft {
  const LandlordPropertyDraft({
    required this.name,
    required this.description,
    required this.address,
    required this.pricePerNight,
    required this.photos,
    required this.mainPhotoIndex,
    this.status = LandlordPropertyStatus.available,
  });

  final String name;
  final String description;
  final LandlordPropertyAddress address;
  final double pricePerNight;
  final List<Uint8List> photos;
  final int mainPhotoIndex;
  final LandlordPropertyStatus status;

  Uint8List get mainPhoto => photos[mainPhotoIndex];

  String get location => '${address.neighborhood}, ${address.city}';
}
