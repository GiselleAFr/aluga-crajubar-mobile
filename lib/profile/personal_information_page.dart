import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../utils/input_formatters.dart';

/// Informações pessoais: o usuário altera nome, telefone e foto.
/// O e-mail é único e fica somente para leitura.
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
  late final TextEditingController _phoneController;
  late final String _initialName;
  late final String _initialPhoneDigits;

  Uint8List? _photoBytes;
  bool _saving = false;

  static String _digits(String? text) =>
      (text ?? '').replaceAll(RegExp(r'\D'), '');

  /// Telefone sem o +55, como a pessoa digita (10 ou 11 dígitos).
  static String _nationalDigits(String? phone) =>
      _digits(phone).replaceFirst(RegExp(r'^55(?=\d{10,11}$)'), '');

  @override
  void initState() {
    super.initState();
    _initialName = widget.user.name.trim();
    _initialPhoneDigits = _nationalDigits(widget.user.phone);

    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(
      text: formatBrazilianPhoneDigits(_initialPhoneDigits),
    );

    // Atualiza as iniciais e o estado do botão Salvar enquanto digita.
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// O botão Salvar só habilita quando há algo novo para enviar.
  bool get _hasChanges =>
      _nameController.text.trim() != _initialName ||
      _digits(_phoneController.text) != _initialPhoneDigits;

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

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    try {
      final user = await widget.authService.updateProfile(
        name: _nameController.text,
        // Mesmo formato do cadastro: +55 + DDD + número.
        phone: '+55${_digits(_phoneController.text)}',
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso.')),
      );
      navigator.pop(user);
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

  String? _validatePhone(String? value) {
    final digits = _digits(value);
    if (digits.length != 10 && digits.length != 11) {
      return 'Informe um telefone válido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: _vinho,
      surfaceTintColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Informações pessoais',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white),
      ),
      leading: IconButton(
        tooltip: 'Voltar',
        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            _readOnlyField(
              label: 'E-mail',
              value: widget.user.email,
              helper: 'O e-mail é único e não pode ser alterado.',
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
                onPressed: (_saving || !_hasChanges) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vinho,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _vinho.withValues(alpha: 0.55),
                  disabledForegroundColor: Colors.white,
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
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
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

  /// Campo que o usuário vê, mas não edita (ex.: e-mail).
  Widget _readOnlyField({
    required String label,
    required String value,
    required String helper,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(color: Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F0EE),
            helperText: helper,
            suffixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: Colors.black45,
            ),
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
              borderSide: BorderSide(color: _borda),
            ),
          ),
        ),
      ],
    ),
  );
}