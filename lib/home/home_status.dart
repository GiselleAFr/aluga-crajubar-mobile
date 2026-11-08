import '../reservation/reservation_pricing.dart';
import '../services/reservation_service.dart';

enum HomeStatusType { landlordPending, activeStay, awaitingApproval }

/// O único card de status exibido na Home (ou nenhum).
class HomeStatus {
  const HomeStatus._(this.type, {this.count = 0, this.reservation});

  factory HomeStatus.landlordPending(int count) =>
      HomeStatus._(HomeStatusType.landlordPending, count: count);

  final HomeStatusType type;
  final int count;
  final Reservation? reservation;

  /// Escolhe o card a partir das reservas do cliente:
  /// hospedagem atual primeiro; senão, solicitação aguardando resposta.
  static HomeStatus? fromReservations(List<Reservation> reservas) {
    final hoje = ReservationPricing.dateOnly(DateTime.now());

    final ativas = reservas.where((r) {
      final entrada = r.checkIn;
      final saida = r.checkOut;
      return r.status == 'confirmed' &&
          entrada != null &&
          saida != null &&
          !entrada.isAfter(hoje) &&
          saida.isAfter(hoje);
    }).toList()..sort((a, b) => b.checkIn!.compareTo(a.checkIn!));

    if (ativas.isNotEmpty) {
      return HomeStatus._(
        HomeStatusType.activeStay,
        reservation: ativas.first,
      );
    }

    // Pendentes cuja data de entrada já passou não aguardam mais ninguém.
    final pendentes = reservas
        .where(
          (r) =>
              r.status == 'pending' &&
              r.checkIn != null &&
              !r.checkIn!.isBefore(hoje),
        )
        .toList();

    if (pendentes.isNotEmpty) {
      return HomeStatus._(
        HomeStatusType.awaitingApproval,
        count: pendentes.length,
        reservation: pendentes.first,
      );
    }

    return null;
  }
}