import 'package:flutter/material.dart';

import '../home/components/home_navigation.dart';
import '../responsive_content.dart';
import '../services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.initialNavigationIndex,
    required this.onNavigate,
  });

  final int initialNavigationIndex;
  final ValueChanged<int> onNavigate;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _authService = AuthService();
  late int _navigationIndex;
  late Future<AuthProfile> _profileFuture;
  late Future<List<StayRecord>> _staysFuture;

  bool get _showStays => _navigationIndex == 3;

  @override
  void initState() {
    super.initState();
    _navigationIndex = widget.initialNavigationIndex;
    _reload();
  }

  void _reload() {
    _profileFuture = _authService.profile();
    _staysFuture = _authService.stayHistory();
  }

  void _selectNavigation(int index) {
    if (index < 3) {
      widget.onNavigate(index);
      return;
    }
    setState(() => _navigationIndex = index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F7F5),
    appBar: AppBar(
      title: Text(_showStays ? 'Minhas hospedagens' : 'Meu perfil'),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF963333),
    ),
    body: SafeArea(
      child: ResponsiveContent(
        maxWidth: 760,
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (!_showStays) _profileSection(),
            if (_showStays) _staysSection(),
          ],
        ),
      ),
    ),
    bottomNavigationBar: HomeBottomNavigation(
      indiceSelecionado: _navigationIndex,
      onItemSelecionado: _selectNavigation,
    ),
  );

  Widget _profileSection() => FutureBuilder<AuthProfile>(
    future: _profileFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (snapshot.hasError) {
        return _errorState(snapshot.error.toString());
      }

      final profile = snapshot.requireData;
      return Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFF7E9E4),
                child: Icon(Icons.person_outline, color: Color(0xFF963333)),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              _detailRow(Icons.email_outlined, profile.email),
              if (profile.phone?.isNotEmpty == true)
                _detailRow(Icons.phone_outlined, profile.phone!),
              _detailRow(
                Icons.badge_outlined,
                profile.isLandlord ? 'Locador' : 'Cliente',
              ),
              const Divider(height: 28),
              Text(
                'Hospedagens concluídas: ${profile.completedStaysCount}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _navigationIndex = 3),
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico de hospedagens'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar perfil'),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _staysSection() => FutureBuilder<List<StayRecord>>(
    future: _staysFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (snapshot.hasError) {
        return _errorState(snapshot.error.toString());
      }

      final stays = snapshot.requireData;
      if (stays.isEmpty) {
        return const Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Você ainda não possui hospedagens no histórico.'),
          ),
        );
      }
      return Column(
        children: stays
            .map(
              (stay) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF7E9E4),
                    child: Icon(Icons.home_outlined, color: Color(0xFF963333)),
                  ),
                  title: Text(stay.propertyName),
                  subtitle: Text(
                    [
                      if (stay.city?.isNotEmpty == true) stay.city!,
                      if (stay.checkIn != null || stay.checkOut != null)
                        '${stay.checkIn ?? '—'} – ${stay.checkOut ?? '—'}',
                      'Status: ${stay.status}',
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '${stay.currency} ${stay.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF963333),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    },
  );

  Widget _detailRow(IconData icon, String value) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    ),
  );

  Widget _errorState(String message) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: Color(0xFF963333)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );

  void _refresh() => setState(_reload);
}
