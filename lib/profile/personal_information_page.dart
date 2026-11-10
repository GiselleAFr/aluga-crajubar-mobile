import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../utils/input_formatters.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({
    super.key,
    required this.user,
    required this.authService,
  });

  final AuthUser user;
  final AuthService authService;

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  static const _vinho = Color(0xFF963333);
  static const _borda = Color(0xFFE7C7B8);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cpfController;
  late final TextEditingController _phoneController;

  Uint8List? _photoBytes;
  bool _saving = false;
  bool _loadingCpf = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(
      text: formatBrazilianPhoneDigits(
        (widget.user.phone ?? '')
            .replaceAll(RegExp(r'\D'), '')
            .replaceFirst(RegExp(r'^55(?=\d{10,11}$)'), ''),
      ),
    );
    _cpfController = TextEditingController();
    _loadCpf();
  }

  Future<void> _loadCpf() async {
    String? cpf;
    try {
      cpf = await widget.authService.profileCpf(widget.user.id);
    } catch (_) {
      // Em dispositivos sem armazenamento seguro disponível, o formulário
      // continua utilizável; o CPF será solicitado novamente.
    }
    if (!mounted) return;
    _cpfController.text = cpf ?? '';
    setState(() => _loadingCpf = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _selectPhoto() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Imagens',
            extensions: ['jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        if (mounted) _message('Escolha uma imagem de até 5 MB.');
        return;
      }
      if (mounted) setState(() => _photoBytes = bytes);
    } catch (_) {
      if (mounted) _message('Não foi possível abrir a imagem selecionada.');
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final user = await widget.authService.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      await widget.authService.saveProfileCpf(
        userId: user.id,
        cpf: _cpfController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(user);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message(error.fieldErrors.values.firstOrNull ?? error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _message('Não foi possível salvar suas alterações. Tente novamente.');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Informe $label.';
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _required(value, 'seu e-mail');
    if (required != null) return required;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  String? _validateCpf(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return 'Informe um CPF com 11 dígitos.';
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digits))
      return 'Informe um CPF válido.';

    int digitAt(int end) {
      var sum = 0;
      for (var index = 0; index < end; index++) {
        sum += int.parse(digits[index]) * (end + 1 - index);
      }
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    if (digitAt(9) != int.parse(digits[9]) ||
        digitAt(10) != int.parse(digits[10])) {
      return 'Informe um CPF válido.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10 && digits.length != 11) {
      return 'Informe um telefone válido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Informações Pessoais',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
      ),
      leading: IconButton(
        tooltip: 'Voltar',
        icon: const Icon(Icons.arrow_back, color: _vinho),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _borda),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          children: [
            Center(
              child: Column(
                children: [
                  Semantics(
                    button: true,
                    label: 'Alterar foto de perfil',
                    child: InkWell(
                      onTap: _selectPhoto,
                      borderRadius: BorderRadius.circular(60),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _borda, width: 2),
                              color: const Color(0xFFF4DED4),
                            ),
                            child: ClipOval(
                              child: _photoBytes == null
                                  ? Center(
                                      child: Text(
                                        _initials,
                                        style: const TextStyle(
                                          color: _vinho,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 34,
                                        ),
                                      ),
                                    )
                                  : Image.memory(
                                      _photoBytes!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _vinho,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Toque para alterar a foto de perfil',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _field(
              label: 'Nome Completo',
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) => _required(value, 'seu nome'),
            ),
            _field(
              label: 'E-mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _field(
              label: 'CPF',
              controller: _cpfController,
              keyboardType: TextInputType.number,
              inputFormatters: const [
                DigitsMaskInputFormatter(
                  maxDigits: 11,
                  formatDigits: formatCpfDigits,
                ),
              ],
              validator: _validateCpf,
              enabled: !_loadingCpf,
            ),
            _field(
              label: 'Telefone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: const [
                DigitsMaskInputFormatter(
                  maxDigits: 11,
                  formatDigits: formatBrazilianPhoneDigits,
                ),
              ],
              validator: _validatePhone,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving || _loadingCpf ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vinho,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _vinho.withValues(alpha: 0.55),
                  elevation: 4,
                  shadowColor: _vinho.withValues(alpha: 0.28),
                  shape: const StadiumBorder(),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Salvar Alterações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFCFBFA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(17)),
              borderSide: BorderSide(color: _borda),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(17)),
              borderSide: BorderSide(color: _borda),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(17)),
              borderSide: BorderSide(color: _vinho, width: 1.5),
            ),
          ),
        ),
      ],
    ),
  );
}
