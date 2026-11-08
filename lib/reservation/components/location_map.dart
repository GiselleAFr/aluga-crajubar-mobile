import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mapa com o marcador do imóvel (OpenStreetMap).
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
    final ponto = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(initialCenter: ponto, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.aluga_crajubar',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: ponto,
                  width: 45,
                  height: 45,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF963333),
                    size: 42,
                  ),
                ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
