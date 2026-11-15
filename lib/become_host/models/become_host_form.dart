import 'dart:typed_data';

enum HostDocumentType {
  rg('RG'),
  cnh('CNH'),
  passport('Passaporte');

  const HostDocumentType(this.label);

  final String label;
}

class HostDocumentPhoto {
  const HostDocumentPhoto({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class BecomeHostForm {
  const BecomeHostForm({
    required this.fullName,
    required this.cpf,
    required this.birthDate,
    required this.documentType,
    required this.email,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.commercialPhone,
    required this.documentFront,
    required this.documentBack,
  });

  final String fullName;
  final String cpf;
  final DateTime birthDate;
  final HostDocumentType documentType;
  final String email;
  final String primaryPhone;
  final String secondaryPhone;
  final String commercialPhone;
  final HostDocumentPhoto documentFront;
  final HostDocumentPhoto documentBack;
}
