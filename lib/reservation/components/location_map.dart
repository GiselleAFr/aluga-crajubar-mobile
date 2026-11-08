import 'package:flutter/material.dart';

/// Mapa com a localização do imóvel.
class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 240,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFB9D9B0),
                const Color(0xFF95B8A0),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: Icon(
                  Icons.map_outlined,
                  size: 72,
                  color: Color(0xFF2E5D4D),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lat $latitude, Lng $longitude',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}