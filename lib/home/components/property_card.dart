import 'package:flutter/material.dart';

import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onFavoritoPressed, onReservarPressed;
  const PropertyCard({
    super.key,
    required this.property,
    required this.onFavoritoPressed,
    required this.onReservarPressed,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 164,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE8D8D1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .04),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            property.imagem == null || property.imagem!.isEmpty
                ? Container(
                    height: 104,
                    width: double.infinity,
                    color: const Color(0xFFE5DAD3),
                    child: const Center(
                      child: Icon(
                        Icons.home_work_outlined,
                        size: 35,
                        color: Color(0xFF963333),
                      ),
                    ),
                  )
                : Image.network(
                    property.imagem!,
                    height: 104,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 104,
                      width: double.infinity,
                      color: const Color(0xFFE5DAD3),
                      child: const Center(
                        child: Icon(
                          Icons.home_work_outlined,
                          size: 35,
                          color: Color(0xFF963333),
                        ),
                      ),
                    ),
                  ),
            if (property.nota != null)
              Positioned(
                top: 7,
                left: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 11,
                        color: Color(0xFFE7A93D),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        property.nota!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: onFavoritoPressed,
                icon: Icon(
                  property.favorito ? Icons.favorite : Icons.favorite_border,
                  color: property.favorito ? Colors.red : Colors.white,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                property.local,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF963333),
                    fontSize: 10,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'R\$ ${property.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' ${property.periodoPreco}',
                      style: TextStyle(color: Colors.black54, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 23,
                child: ElevatedButton(
                  onPressed: onReservarPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF963333),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Reservar',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
