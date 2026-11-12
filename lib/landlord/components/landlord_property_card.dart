import 'package:flutter/material.dart';

import '../models/landlord_property_draft.dart';

class LandlordPropertyCard extends StatelessWidget {
  const LandlordPropertyCard({
    super.key,
    required this.property,
    required this.onEdit,
    required this.onDelete,
  });

  final LandlordPropertyDraft property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _wine = Color(0xFFA83232);

  Color get _statusColor => switch (property.status) {
    LandlordPropertyStatus.available => const Color(0xFF26734D),
    LandlordPropertyStatus.rented => const Color(0xFF315D9B),
    LandlordPropertyStatus.unavailable => const Color(0xFF666666),
  };

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('landlord-property-${property.name}'),
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE8D8D1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.58,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                property.mainPhoto,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              ),
              Positioned(
                top: 7,
                left: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    property.status.label,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                property.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'R\$ ${property.pricePerNight.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: _wine,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text: ' / noite',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Excluir imóvel',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFA83232),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _wine,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Editar imóvel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _imagePlaceholder() => Container(
    width: double.infinity,
    color: const Color(0xFFE5DAD3),
    child: const Center(
      child: Icon(Icons.home_work_outlined, size: 36, color: _wine),
    ),
  );
}
