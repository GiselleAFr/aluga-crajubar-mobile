import 'package:flutter/material.dart';

import '../home/components/home_navigation.dart';
import 'models/landlord_property_address.dart';
import 'models/landlord_property_draft.dart';
import 'landlord_property_photos_page.dart';

class LandlordPropertyAddressPage extends StatefulWidget {
  static const routeName = landlordPropertyAddressRouteName;

  const LandlordPropertyAddressPage({
    super.key,
    required this.onItemSelecionado,
    this.onPropertyCreated,
  });

  final ValueChanged<int> onItemSelecionado;
  final ValueChanged<LandlordPropertyDraft>? onPropertyCreated;

  @override
  State<LandlordPropertyAddressPage> createState() =>
      _LandlordPropertyAddressPageState();
}

class _LandlordPropertyAddressPageState
    extends State<LandlordPropertyAddressPage> {
  static const _wine = Color(0xFF943131);
  static const _almond = Color(0xFFD9BDA6);
  static const _muted = Color(0xFF666666);

  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _muted, fontSize: 14),
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: _wine, size: 19),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: _almond),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: _almond),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: const BorderSide(color: _wine, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
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
      ],
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LandlordPropertyPhotosPage(
          onPropertyCreated: widget.onPropertyCreated,
          address: LandlordPropertyAddress(
            city: _cityController.text.trim(),
            neighborhood: _neighborhoodController.text.trim(),
            street: _streetController.text.trim(),
            number: _numberController.text.trim(),
            complement: _complementController.text.trim(),
          ),
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
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: const BoxDecoration(
              color: _wine,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadastre seu imóvel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Preencha os dados para publicar seu anúncio',
                  style: TextStyle(color: _almond, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cadastre seu imóvel',
                    style: TextStyle(
                      color: _wine,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Preencha os dados abaixo para publicar seu anúncio com rapidez e segurança.',
                    style: TextStyle(color: _muted, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _almond),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C943131),
                            blurRadius: 8,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Endereço do imóvel',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Informe os dados completos para facilitar a localização e o contato com interessados.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildField(
                            label: 'Cidade',
                            hint: 'Digite a cidade',
                            controller: _cityController,
                            icon: Icons.location_on_outlined,
                            validator: _required,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Bairro',
                            hint: 'Digite o bairro',
                            controller: _neighborhoodController,
                            icon: Icons.map_outlined,
                            validator: _required,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Rua',
                            hint: 'Digite a rua',
                            controller: _streetController,
                            icon: Icons.alt_route,
                            validator: _required,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildField(
                                  label: 'Número da casa',
                                  hint: 'Nº',
                                  controller: _numberController,
                                  keyboardType: TextInputType.number,
                                  validator: _required,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  label: 'Complemento',
                                  hint: 'Bloco, apto, andar...',
                                  controller: _complementController,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info, color: _wine, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'O endereço completo ajuda a melhorar a visibilidade do anúncio e a reduzir dúvidas de localização.',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _continue,
                              style: FilledButton.styleFrom(
                                backgroundColor: _wine,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Continuar',
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
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: HomeBottomNavigation(
      indiceSelecionado: 5,
      mostrarLocador: true,
      onItemSelecionado: widget.onItemSelecionado,
    ),
  );
}
