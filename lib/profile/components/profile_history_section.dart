import 'package:flutter/material.dart';

import '../../reservation/reservation_pricing.dart';
import '../../services/reservation_service.dart';

/// Hospedagens já concluídas (reservas confirmadas cuja saída já passou).
class ProfileHistorySection extends StatelessWidget {
  const ProfileHistorySection({
    super.key,
    required this.estadias,
    required this.carregando,
    required this.onTap,
    this.erro,
    this.onTentarNovamente,
    this.onVerTodos,
  });

  final List<Reservation> estadias;
  final bool carregando;
  final String? erro;
  final VoidCallback? onTentarNovamente;

  /// Se null, o link "Ver todos" não aparece.
  final VoidCallback? onVerTodos;
  final ValueChanged<Reservation> onTap;

  static const _vinho = Color(0xFF963333);
  static const _borda = Color(0xFFE8D8D1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Histórico',
                style: TextStyle(
                  color: _vinho,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onVerTodos != null)
              InkWell(
                onTap: onVerTodos,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Ver todos',
                    style: TextStyle(
                      color: _vinho,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        const Text(
          'Suas hospedagens concluídas',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        _buildCorpo(),
      ],
    );
  }

  Widget _buildCorpo() {
    if (carregando) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: _vinho)),
      );
    }

    if (erro != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _decoracao(),
        child: Column(
          children: [
            const Text(
              'Não foi possível carregar o histórico.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            if (onTentarNovamente != null)
              TextButton(
                onPressed: onTentarNovamente,
                child: const Text('Tentar novamente'),
              ),
          ],
        ),
      );
    }

    if (estadias.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: _decoracao(),
        child: const Column(
          children: [
            Icon(Icons.history, size: 36, color: Color(0xFFD9A18B)),
            SizedBox(height: 8),
            Text(
              'Nenhuma hospedagem concluída ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Quando uma estadia terminar, ela aparece aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: estadias.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _CartaoEstadia(
          reserva: estadias[index],
          onTap: () => onTap(estadias[index]),
        ),
      ),
    );
  }

  BoxDecoration _decoracao() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: _borda),
  );
}

class _CartaoEstadia extends StatelessWidget {
  const _CartaoEstadia({required this.reserva, required this.onTap});

  final Reservation reserva;
  final VoidCallback onTap;

  Widget _placeholder() => Container(
    width: 190,
    height: 64,
    color: const Color(0xFFE7DDD6),
    child: const Icon(Icons.home_outlined, color: Color(0xFF963333)),
  );

  @override
  Widget build(BuildContext context) {
    final imovel = reserva.property;
    final imagem = imovel?.imagem;
    final local = (imovel != null && imovel.local.isNotEmpty)
        ? imovel.local
        : (reserva.city ?? '');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8D8D1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagem == null || imagem.isEmpty)
              _placeholder()
            else
              Image.network(
                imagem,
                width: 190,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
              child: Text(
                reserva.propertyName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                local,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Text(
                '${ReservationPricing.formatarData(reserva.checkIn)}  →  '
                '${ReservationPricing.formatarData(reserva.checkOut)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF963333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
