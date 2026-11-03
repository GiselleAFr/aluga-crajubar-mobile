
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/reservation_service.dart';
import '../home/components/home_navigation.dart';

class ReservationsPage extends StatefulWidget {
  final ValueChanged<int> onItemSelecionado;
  final VoidCallback onEncontrarHospedagens;

  const ReservationsPage({
    super.key,
    required this.onItemSelecionado,
    required this.onEncontrarHospedagens,
  });

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final ReservationService _reservationService = ReservationService();

  ActiveStay? _activeStay;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarHospedagem();
  }

  @override
  void dispose() {
    _reservationService.close();
    super.dispose();
  }

  Future<void> _carregarHospedagem() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stay = await _reservationService.getActiveStay();

      if (!mounted) return;

      setState(() {
        _activeStay = stay;
        _loading = false;
      });
    } on ReservationApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Não foi possível carregar sua hospedagem.';
        _loading = false;
      });
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Não informada';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;

    return '$dia/$mes/$ano';
  }

  Future<void> _abrirGoogleMaps(ActiveStay stay) async {
    if (!stay.hasCoordinates) return;

    final latitude = stay.latitude!;
    final longitude = stay.longitude!;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    final abriu = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o Google Maps.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        indiceSelecionado: 3,
        onItemSelecionado: widget.onItemSelecionado,
      ),
    );
  }

  
  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF963333),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minhas reservas',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Acompanhe sua hospedagem atual.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFF963333),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF963333),
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_activeStay == null) {
      return _buildEmptyState();
    }

    return _buildActiveStay(_activeStay!);
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            const Text(
              'Não foi possível carregar suas reservas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _carregarHospedagem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF963333),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 35),
          Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE9E1D9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.travel_explore,
              size: 100,
              color: Color(0xFF963333),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sua próxima hospedagem está esperando por você!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Você ainda não está hospedado? Encontre agora mesmo '
            'o lugar ideal para sua estadia no Crajubar!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onEncontrarHospedagens,
              icon: const Icon(Icons.search),
              label: const Text('Encontrar hospedagens'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF963333),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStay(ActiveStay stay) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Você está hospedado em:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stay.propertyName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF963333),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        [
                          if (stay.address != null &&
                              stay.address!.isNotEmpty)
                            stay.address,
                          if (stay.neighborhood != null &&
                              stay.neighborhood!.isNotEmpty)
                            stay.neighborhood,
                          stay.city,
                        ].whereType<String>().join(', '),
                        style: const TextStyle(
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 25),
                _infoRow(
                  Icons.calendar_month_outlined,
                  'Entrada',
                  _formatarData(stay.checkIn),
                ),
                const SizedBox(height: 12),
                _infoRow(
                  Icons.event_available_outlined,
                  'Saída',
                  _formatarData(stay.checkOut),
                ),
                const SizedBox(height: 12),
                _infoRow(
                  Icons.people_outline,
                  'Hóspedes',
                  '${stay.guests}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Localização da hospedagem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (stay.hasCoordinates)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 260,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      stay.latitude!,
                      stay.longitude!,
                    ),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.aluga_crajubar',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            stay.latitude!,
                            stay.longitude!,
                          ),
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
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 42,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'A localização deste imóvel ainda não está disponível.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (stay.hasCoordinates)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _abrirGoogleMaps(stay),
                icon: const Icon(Icons.directions),
                label: const Text('Ver rota no Google Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF963333),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF963333)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF963333), size: 21),
        const SizedBox(width: 9),
        Text(
          '$label:',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
