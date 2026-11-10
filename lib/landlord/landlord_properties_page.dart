import 'package:flutter/material.dart';

import '../home/components/home_navigation.dart';
import '../shared/page_header.dart';
import '../shared/search_field.dart';
import 'components/landlord_property_card.dart';
import 'landlord_property_photos_page.dart';
import 'models/landlord_property_draft.dart';

class LandlordPropertiesPage extends StatefulWidget {
  static const routeName = '/landlord/properties';

  const LandlordPropertiesPage({
    super.key,
    required this.userName,
    required this.onItemSelecionado,
    required this.onAdicionarImovel,
    this.onPropertiesChanged,
    this.properties = const [],
  });

  final String userName;
  final ValueChanged<int> onItemSelecionado;
  final void Function(ValueChanged<LandlordPropertyDraft> onPropertyCreated)
  onAdicionarImovel;
  final ValueChanged<List<LandlordPropertyDraft>>? onPropertiesChanged;
  final List<LandlordPropertyDraft> properties;

  @override
  State<LandlordPropertiesPage> createState() => _LandlordPropertiesPageState();
}

class _LandlordPropertiesPageState extends State<LandlordPropertiesPage> {
  static const _wine = Color(0xFF963333);

  final _searchController = TextEditingController();
  late final List<LandlordPropertyDraft> _properties;

  @override
  void initState() {
    super.initState();
    _properties = List.of(widget.properties);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUnavailableMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ficará disponível quando houver imóveis.'),
      ),
    );
  }

  void _propertyCreated(LandlordPropertyDraft property) {
    setState(() => _properties.insert(0, property));
    _notifyPropertiesChanged();
  }

  void _editProperty(int index) {
    final property = _properties[index];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LandlordPropertyPhotosPage(
          address: property.address,
          initialProperty: property,
          onPropertyCreated: (updatedProperty) {
            setState(() => _properties[index] = updatedProperty);
            _notifyPropertiesChanged();
            Navigator.of(context).popUntil(
              (route) =>
                  route.settings.name == LandlordPropertiesPage.routeName ||
                  route.isFirst,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imóvel de exemplo atualizado.')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProperty(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir imóvel?'),
        content: Text(
          'O imóvel "${_properties[index].name}" será removido desta demonstração.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    final deletedName = _properties[index].name;
    setState(() => _properties.removeAt(index));
    _notifyPropertiesChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imóvel "$deletedName" removido da demonstração.'),
      ),
    );
  }

  void _notifyPropertiesChanged() {
    widget.onPropertiesChanged?.call(List.unmodifiable(_properties));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF9FAFB),
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(
            titulo: 'Olá, ${widget.userName}!',
            subtitulo: 'Gerencie seus imóveis disponíveis e locados',
            child: SearchField(
              controller: _searchController,
              hintText: 'Buscar meus imóveis...',
              onSubmitted: (_) => _showUnavailableMessage('A busca'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meus imóveis',
                    style: TextStyle(
                      color: _wine,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acompanhe o status atual de cada propriedade e organize sua carteira de locação.',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IMÓVEIS ATUALMENTE',
                              style: TextStyle(
                                color: _wine,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Status, preço e disponibilidade',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Ordenar imóveis',
                        onSelected: (_) =>
                            _showUnavailableMessage('A ordenação'),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'recentes',
                            child: Text('Mais recentes'),
                          ),
                          PopupMenuItem(
                            value: 'menor-preco',
                            child: Text('Menor preço'),
                          ),
                          PopupMenuItem(
                            value: 'maior-preco',
                            child: Text('Maior preço'),
                          ),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 2, left: 8),
                          child: Text(
                            'Ordenar',
                            style: TextStyle(
                              color: _wine,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_properties.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (
                      var index = 0;
                      index < _properties.length;
                      index++
                    ) ...[
                      LandlordPropertyCard(
                        property: _properties[index],
                        onEdit: () => _editProperty(index),
                        onDelete: () => _confirmDeleteProperty(index),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => widget.onAdicionarImovel(_propertyCreated),
      backgroundColor: _wine,
      foregroundColor: Colors.white,
      tooltip: 'Adicionar imóvel',
      child: const Icon(Icons.add, size: 28),
    ),
    bottomNavigationBar: HomeBottomNavigation(
      indiceSelecionado: 5,
      mostrarLocador: true,
      onItemSelecionado: widget.onItemSelecionado,
    ),
  );
}
