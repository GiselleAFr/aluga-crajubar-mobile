import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/landlord_property_service.dart';
import 'models/landlord_property_address.dart';
import 'models/landlord_property_draft.dart';

class LandlordPropertyDetailsPage extends StatefulWidget {
  const LandlordPropertyDetailsPage({
    super.key,
    required this.address,
    required this.photos,
    required this.mainPhotoIndex,
    this.initialProperty,
    this.onPropertyCreated,
  });

  final LandlordPropertyAddress address;
  final List<LandlordPropertyPhoto> photos;
  final int mainPhotoIndex;
  final LandlordPropertyDraft? initialProperty;
  final Future<void> Function(LandlordPropertyDraft property)?
  onPropertyCreated;

  @override
  State<LandlordPropertyDetailsPage> createState() =>
      _LandlordPropertyDetailsPageState();
}

class _LandlordPropertyDetailsPageState
    extends State<LandlordPropertyDetailsPage> {
  static const _wine = Color(0xFFA83232);
  static const _almond = Color(0xFFE8BDBD);
  static const _muted = Color(0xFF666666);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  LandlordPropertyStatus _status = LandlordPropertyStatus.available;
  LandlordPropertyType? _type;
  LandlordPropertyPurpose? _purpose;
  LandlordRentalPeriod? _rentalPeriod;
  bool _isSaving = false;

  bool get _isEditing => widget.initialProperty != null;

  @override
  void initState() {
    super.initState();
    final property = widget.initialProperty;
    if (property != null) {
      _nameController.text = property.name;
      _descriptionController.text = property.description;
      _priceController.text = property.price
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _status = property.status;
      _type = property.type;
      _purpose = property.purpose;
      _rentalPeriod = property.rentalPeriod;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;

  String? _validatePrice(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;

    final normalizedPrice = value!.replaceAll(',', '.');
    final price = double.tryParse(normalizedPrice);
    if (price == null || price <= 0) {
      return 'Informe um preço maior que zero';
    }

    return null;
  }

  String get _priceLabel {
    if (_purpose == LandlordPropertyPurpose.sale) return 'Preço de venda';
    if (_rentalPeriod == LandlordRentalPeriod.daily) return 'Preço por diária';
    if (_rentalPeriod == LandlordRentalPeriod.monthly) return 'Preço mensal';
    return 'Preço do imóvel';
  }

  String get _priceHint {
    if (_purpose == LandlordPropertyPurpose.sale) return 'Ex.: 250.000,00';
    if (_rentalPeriod == LandlordRentalPeriod.daily) return 'Ex.: 350,00';
    if (_rentalPeriod == LandlordRentalPeriod.monthly) return 'Ex.: 1.500,00';
    return 'Informe o valor';
  }

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: _almond),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: _almond),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: _wine, width: 1.5),
    ),
  );

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter> inputFormatters = const [],
    int maxLines = 1,
    Widget? prefix,
    String? helperText,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: _wine,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _muted, fontSize: 14),
          prefix: prefix,
          alignLabelWithHint: maxLines > 1,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _almond),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _almond),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _wine, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1.5,
            ),
          ),
        ),
      ),
      if (helperText != null) ...[
        const SizedBox(height: 6),
        Text(
          helperText,
          style: const TextStyle(color: _muted, fontSize: 11, height: 1.4),
        ),
      ],
    ],
  );

  void _editAddress() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == landlordPropertyAddressRouteName,
    );
  }

  Future<void> _continue() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final normalizedPrice = _priceController.text.replaceAll(',', '.');
    final property = LandlordPropertyDraft(
      id: widget.initialProperty?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: widget.address,
      price: double.parse(normalizedPrice),
      photos: List.unmodifiable(widget.photos),
      mainPhotoIndex: widget.mainPhotoIndex,
      type: _type!,
      purpose: _purpose!,
      rentalPeriod: _purpose == LandlordPropertyPurpose.rental
          ? _rentalPeriod
          : null,
      status: _status,
    );

    final onPropertyCreated = widget.onPropertyCreated;
    if (onPropertyCreated != null) {
      setState(() => _isSaving = true);
      try {
        await onPropertyCreated(property);
      } on LandlordPropertyApiException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.message)));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro de demonstração concluído.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FAFB),
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: _wine,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14A83232),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Voltar',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    fixedSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing ? 'Edição de imóvel' : 'Etapa 5 de 5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing ? 'Editar imóvel' : 'Detalhes do imóvel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isEditing
                      ? 'Atualize as informações do seu imóvel.'
                      : 'Informe as características e os valores do imóvel.',
                  style: TextStyle(
                    color: Color(0xFFF7DADA),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'SOBRE O IMÓVEL',
                      style: TextStyle(
                        color: _wine,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Nome do imóvel',
                      hint: 'Ex.: Pousada Padre Cícero',
                      controller: _nameController,
                      validator: _required,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LandlordPropertyType>(
                      initialValue: _type,
                      decoration: _dropdownDecoration('Tipo do imóvel'),
                      validator: (value) =>
                          value == null ? 'Selecione o tipo do imóvel' : null,
                      items: LandlordPropertyType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (type) => setState(() => _type = type),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Descrição do imóvel',
                      hint:
                          'Descreva os espaços, diferenciais e comodidades...',
                      controller: _descriptionController,
                      validator: _required,
                      maxLines: 5,
                      helperText: 'Uma descrição clara ajuda seus hóspedes.',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'FINALIDADE',
                      style: TextStyle(
                        color: _wine,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LandlordPropertyPurpose>(
                      initialValue: _purpose,
                      decoration: _dropdownDecoration('Finalidade'),
                      validator: (value) =>
                          value == null ? 'Selecione a finalidade' : null,
                      items: LandlordPropertyPurpose.values
                          .map(
                            (purpose) => DropdownMenuItem(
                              value: purpose,
                              child: Text(purpose.label),
                            ),
                          )
                          .toList(),
                      onChanged: (purpose) {
                        setState(() {
                          _purpose = purpose;
                          _rentalPeriod =
                              purpose == LandlordPropertyPurpose.rental
                              ? (_rentalPeriod ?? LandlordRentalPeriod.daily)
                              : null;
                        });
                      },
                    ),
                    if (_purpose == LandlordPropertyPurpose.rental) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<LandlordRentalPeriod>(
                        initialValue: _rentalPeriod,
                        decoration: _dropdownDecoration('Período de locação'),
                        validator: (value) => value == null
                            ? 'Selecione o período de locação'
                            : null,
                        items: LandlordRentalPeriod.values
                            .map(
                              (period) => DropdownMenuItem(
                                value: period,
                                child: Text(period.label),
                              ),
                            )
                            .toList(),
                        onChanged: (period) =>
                            setState(() => _rentalPeriod = period),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'STATUS DO IMÓVEL',
                      style: TextStyle(
                        color: _wine,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LandlordPropertyStatus>(
                      initialValue: _status,
                      decoration: InputDecoration(
                        labelText: 'Disponibilidade',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: _almond),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: _almond),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: _wine,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: LandlordPropertyStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (status) {
                        if (status != null) {
                          setState(() => _status = status);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'LOCALIZAÇÃO',
                            style: TextStyle(
                              color: _wine,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!_isEditing)
                          TextButton.icon(
                            onPressed: _editAddress,
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('Editar'),
                            style: TextButton.styleFrom(
                              foregroundColor: _wine,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _almond),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: _wine,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.address.formattedAddress,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _priceLabel.toUpperCase(),
                      style: TextStyle(
                        color: _wine,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: _priceLabel,
                      hint: _priceHint,
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return RegExp(r'^\d*([,.]\d{0,2})?$')
                                  .hasMatch(newValue.text)
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      validator: _validatePrice,
                      prefix: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          'R\$',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      helperText: 'O valor será exibido conforme a finalidade selecionada.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _continue,
                        style: FilledButton.styleFrom(
                          backgroundColor: _wine,
                          shape: const StadiumBorder(),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Salvar alterações'
                                    : 'Concluir cadastro',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
