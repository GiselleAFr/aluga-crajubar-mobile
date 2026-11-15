const landlordPropertyAddressRouteName = '/landlord/property-address';

class LandlordPropertyAddress {
  const LandlordPropertyAddress({
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.number,
    required this.complement,
  });

  final String city;
  final String neighborhood;
  final String street;
  final String number;
  final String complement;

  String get formattedAddress {
    final streetAddress = [
      street.trim(),
      number.trim(),
    ].where((part) => part.isNotEmpty).join(', ');
    final addressWithComplement = complement.isEmpty
        ? streetAddress
        : '$streetAddress, $complement';
    return [
      neighborhood,
      addressWithComplement,
      city,
    ].where((part) => part.isNotEmpty).join(' · ');
  }
}
