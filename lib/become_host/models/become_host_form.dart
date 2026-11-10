enum HostDocumentType {
  rg('RG'),
  cnh('CNH'),
  passport('Passaporte');

  const HostDocumentType(this.label);

  final String label;
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
  });

  final String fullName;
  final String cpf;
  final DateTime birthDate;
  final HostDocumentType documentType;
  final String email;
  final String primaryPhone;
  final String secondaryPhone;
  final String commercialPhone;
}
