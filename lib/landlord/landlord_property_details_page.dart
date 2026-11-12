import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<Uint8List> photos;
  final int mainPhotoIndex;
  final LandlordPropertyDraft? initialProperty;
  final ValueChanged<LandlordPropertyDraft>? onPropertyCreated;

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

  bool get _isEditing => widget.initialProperty != null;

  @override
  void initState() {
    super.initState();
    final property = widget.initialProperty;
    if (property != null) {
      _nameController.text = property.name;
      _descriptionController.text = property.description;
      _priceController.text = property.pricePerNight
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _status = property.status;
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

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final normalizedPrice = _priceController.text.replaceAll(',', '.');
    final property = LandlordPropertyDraft(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: widget.address,
      pricePerNight: double.parse(normalizedPrice),
      photos: List.unmodifiable(widget.photos),
      mainPhotoIndex: widget.mainPhotoIndex,
      status: _status,
    );

    final onPropertyCreated = widget.onPropertyCreated;
    if (onPropertyCreated != null) {
      onPropertyCreated(property);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cadastro de demonstração concluído. A publicação ainda não está integrada.',
        ),
      ),
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
                      ? 'Atualize as informações do seu imóvel de demonstração.'
                      : 'Conte o que torna sua hospedagem especial.',
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
                    const Text(
                      'PREÇO DA ESTADIA',
                      style: TextStyle(
                        color: _wine,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Preço por noite',
                      hint: 'Ex.: 350,00',
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
                      helperText: 'Valor de exemplo para demonstração; ainda não será publicado.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _continue,
                        style: FilledButton.styleFrom(
                          backgroundColor: _wine,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          _isEditing
                              ? 'Salvar alterações'
                              : 'Concluir cadastro',
                          style: TextStyle(
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
