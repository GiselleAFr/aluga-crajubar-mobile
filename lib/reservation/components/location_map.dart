import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mapa com o marcador do imóvel (OpenStreetMap).
///
/// Se as imagens do mapa não carregarem (bloqueio do servidor público do
/// OpenStreetMap, rede, extensão do navegador...), mostra um aviso em vez de
/// deixar uma área vazia.
class LocationMap extends StatefulWidget {
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
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  /// Identificação do app para o servidor de mapas. O OpenStreetMap bloqueia
  /// identificações genéricas (como "com.example.app"), então use um nome
  /// próprio do projeto.
  static const _userAgent = 'br.alugacrajubar.mobile';

  bool _tilesFalharam = false;

  void _marcarFalha() {
    if (_tilesFalharam) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _tilesFalharam = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ponto = LatLng(widget.latitude, widget.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: ponto, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: _userAgent,
                  errorTileCallback: (tile, error, stackTrace) => _marcarFalha(),
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
            if (_tilesFalharam)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.map_outlined, size: 18, color: Color(0xFF8A5A00)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'O mapa não carregou. Use “Ver rota no Google Maps” '
                          'para abrir o local.',
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}