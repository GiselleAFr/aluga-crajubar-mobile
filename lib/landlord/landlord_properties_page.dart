import 'package:flutter/material.dart';

import '../home/components/home_navigation.dart';
import '../shared/page_header.dart';
import '../shared/search_field.dart';
import 'components/landlord_property_card.dart';
import 'landlord_property_photos_page.dart';
import 'models/landlord_property_draft.dart';
import '../services/landlord_property_service.dart';

class LandlordPropertiesPage extends StatefulWidget {
  static const routeName = '/landlord/properties';

  const LandlordPropertiesPage({
    super.key,
    required this.userName,
    required this.onItemSelecionado,
    required this.onAdicionarImovel,
    this.onPropertiesChanged,
    this.onSaveProperty,
    this.onDeleteProperty,
    this.properties = const [],
  });

  final String userName;
  final ValueChanged<int> onItemSelecionado;
  final void Function(
    Future<void> Function(LandlordPropertyDraft property) onPropertyCreated,
  )
  onAdicionarImovel;
  final ValueChanged<List<LandlordPropertyDraft>>? onPropertiesChanged;
  final Future<LandlordPropertyDraft> Function(LandlordPropertyDraft property)?
  onSaveProperty;
  final Future<void> Function(int id)? onDeleteProperty;
  final List<LandlordPropertyDraft> properties;

  @override
  State<LandlordPropertiesPage> createState() => _LandlordPropertiesPageState();
}

class _LandlordPropertiesPageState extends State<LandlordPropertiesPage> {
  static const _wine = Color(0xFF963333);

  final _searchController = TextEditingController();
  late final List<LandlordPropertyDraft> _properties;
  String _sort = 'recentes';

  @override
  void initState() {
    super.initState();
    _properties = List.of(widget.properties);
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    if (mounted) setState(() {});
  }

  List<int> get _visiblePropertyIndexes {
    final query = _searchController.text.trim().toLowerCase();
    final indexes = List<int>.generate(_properties.length, (index) => index)
      ..removeWhere((index) {
        if (query.isEmpty) return false;
        final property = _properties[index];
        return !property.name.toLowerCase().contains(query) &&
            !property.location.toLowerCase().contains(query);
      });

    if (_sort == 'menor-preco') {
      indexes.sort(
        (left, right) =>
            _properties[left].price.compareTo(_properties[right].price),
      );
    } else if (_sort == 'maior-preco') {
      indexes.sort(
        (left, right) =>
            _properties[right].price.compareTo(_properties[left].price),
      );
    }

    return indexes;
  }

  Future<void> _propertyCreated(LandlordPropertyDraft property) async {
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
          onPropertyCreated: (updatedProperty) async {
            final save = widget.onSaveProperty;
            final savedProperty = save == null
                ? updatedProperty
                : await save(updatedProperty);
            if (!mounted) return;
            setState(() => _properties[index] = savedProperty);
            _notifyPropertiesChanged();
            Navigator.of(context).popUntil(
              (route) =>
                  route.settings.name == LandlordPropertiesPage.routeName ||
                  route.isFirst,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imóvel atualizado com sucesso.')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProperty(int index) async {
    final messenger = ScaffoldMessenger.of(context);
    final property = _properties[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir imóvel?'),
        content: Text(
          property.id == null
              ? 'O imóvel "${property.name}" será removido desta demonstração.'
              : 'O imóvel "${property.name}" será excluído da sua conta.',
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
    if (property.id != null) {
      final delete = widget.onDeleteProperty;
      if (delete == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('A exclusão pela API não está disponível.'),
          ),
        );
        return;
      }
      try {
        await delete(property.id!);
      } on LandlordPropertyApiException catch (error) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
        return;
      }
    }

    final deletedName = property.name;
    setState(() => _properties.removeAt(index));
    _notifyPropertiesChanged();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          property.id == null
              ? 'Imóvel "$deletedName" removido da demonstração.'
              : 'Imóvel "$deletedName" excluído com sucesso.',
        ),
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
              onSubmitted: (_) => _handleSearchChanged(),
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
                        onSelected: (sort) => setState(() => _sort = sort),
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
                  if (_properties.isNotEmpty &&
                      _visiblePropertyIndexes.isEmpty) ...[
                    const SizedBox(height: 24),
                    const Center(child: Text('Nenhum imóvel encontrado.')),
                  ],
                  if (_visiblePropertyIndexes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final index in _visiblePropertyIndexes) ...[
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
