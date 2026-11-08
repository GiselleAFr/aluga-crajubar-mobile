import 'package:flutter/material.dart';

import 'components/document_upload_field.dart';
import 'components/form_section.dart';
import 'components/labeled_form_field.dart';
import 'models/become_host_form.dart';

class BecomeHostPage extends StatefulWidget {
  const BecomeHostPage({super.key, this.onSubmit});

  final ValueChanged<BecomeHostForm>? onSubmit;

  @override
  State<BecomeHostPage> createState() => _BecomeHostPageState();
}

class _BecomeHostPageState extends State<BecomeHostPage> {
  static const _backgroundColor = Color(0xFFF9FAFB);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cpfController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;
  late final TextEditingController _primaryPhoneController;
  late final TextEditingController _secondaryPhoneController;
  late final TextEditingController _commercialPhoneController;

  HostDocumentType _documentType = HostDocumentType.rg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cpfController = TextEditingController();
    _birthDateController = TextEditingController();
    _emailController = TextEditingController();
    _primaryPhoneController = TextEditingController();
    _secondaryPhoneController = TextEditingController();
    _commercialPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _commercialPhoneController.dispose();
    super.dispose();
  }

  String? _requiredField(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: Theme.of(context).colorScheme.primary),
        ),
        child: child!,
      ),
    );
    if (selectedDate == null || !mounted) return;

    setState(() {
      _birthDateController.text =
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}';
    });
  }

  void _showUploadUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A seleção de documentos ainda não está disponível.'),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final birthDateParts = _birthDateController.text.split('/');
    final birthDate = DateTime(
      int.parse(birthDateParts[2]),
      int.parse(birthDateParts[1]),
      int.parse(birthDateParts[0]),
    );
    final form = BecomeHostForm(
      fullName: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      birthDate: birthDate,
      documentType: _documentType,
      email: _emailController.text.trim(),
      primaryPhone: _primaryPhoneController.text.trim(),
      secondaryPhone: _secondaryPhoneController.text.trim(),
      commercialPhone: _commercialPhoneController.text.trim(),
    );

    if (widget.onSubmit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O cadastro de locador ainda não está integrado.'),
        ),
      );
      return;
    }

    widget.onSubmit!(form);
  }

  Widget _documentTypeButton(HostDocumentType documentType) {
    final selected = _documentType == documentType;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => setState(() => _documentType = documentType),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? primaryColor : const Color(0xFFD9BDA6),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                documentType.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD9BDA6))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF943131),
                size: 16,
              ),
              tooltip: 'Voltar',
            ),
          ),
          Expanded(
            child: Text(
              'Tornar-se Locador',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation() => FormSection(
    title: 'Dados Pessoais',
    children: [
      LabeledTextFormField(
        label: 'Nome Completo',
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        validator: _requiredField,
      ),
      LabeledTextFormField(
        label: 'CPF',
        controller: _cpfController,
        keyboardType: TextInputType.number,
        hintText: '123.456.789-00',
        validator: _requiredField,
      ),
      LabeledTextFormField(
        label: 'Data de Nascimento',
        controller: _birthDateController,
        hintText: 'dd/mm/aaaa',
        readOnly: true,
        onTap: _selectBirthDate,
        validator: _requiredField,
        suffix: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Icon(
            Icons.calendar_today_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
      ),
    ],
  );

  Widget _buildIdentityInformation() => FormSection(
    title: 'Documento de Identidade',
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Documento',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _documentTypeButton(HostDocumentType.rg),
              const SizedBox(width: 8),
              _documentTypeButton(HostDocumentType.cnh),
              const SizedBox(width: 8),
              _documentTypeButton(HostDocumentType.passport),
            ],
          ),
        ],
      ),
      Column(
        children: [
          DocumentUploadField(
            label: 'Enviar foto do documento (frente)',
            onPressed: _showUploadUnavailable,
          ),
          const SizedBox(height: 12),
          DocumentUploadField(
            label: 'Enviar foto do documento (verso)',
            onPressed: _showUploadUnavailable,
          ),
        ],
      ),
      const Text(
        'A foto deve estar legível e sem cortes',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF666666), fontSize: 11),
      ),
    ],
  );

  Widget _buildContactInformation() => FormSection(
    title: 'Dados de Contato',
    children: [
      LabeledTextFormField(
        label: 'E-mail cadastrado',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      LabeledTextFormField(
        label: 'Telefone Principal',
        controller: _primaryPhoneController,
        keyboardType: TextInputType.phone,
        hintText: '(11) 99999-9999',
        validator: _requiredField,
      ),
      LabeledTextFormField(
        label: 'Telefone Secundário',
        controller: _secondaryPhoneController,
        keyboardType: TextInputType.phone,
        hintText: '(00) 00000-0000',
      ),
      LabeledTextFormField(
        label: 'Telefone Comercial (Opcional)',
        controller: _commercialPhoneController,
        keyboardType: TextInputType.phone,
        hintText: '(00) 0000-0000',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: const Icon(
                                      Icons.home_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coloque seus imóveis para alugar e comece a ganhar!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Alugue por temporada, gerencie suas reservas e tenha total segurança no recebimento.',
                                        style: TextStyle(
                                          color: Color(0xFFBAD2DA),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildPersonalInformation(),
                          const SizedBox(height: 24),
                          _buildIdentityInformation(),
                          const SizedBox(height: 24),
                          _buildContactInformation(),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Enviar Cadastro de Locador',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Seu cadastro será analisado em até 48 horas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
