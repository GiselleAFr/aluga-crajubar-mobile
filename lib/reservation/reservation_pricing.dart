class ReservationPricing {
  const ReservationPricing._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Equivalente ao Carbon::addMonthNoOverflow().
  static DateTime addMonthNoOverflow(DateTime d) {
    final ultimoDiaDoProximoMes = DateTime(d.year, d.month + 2, 0).day;
    final dia = d.day > ultimoDiaDoProximoMes ? ultimoDiaDoProximoMes : d.day;
    return DateTime(d.year, d.month + 1, dia);
  }

  /// Check-out de uma reserva mensal de [meses] meses completos.
  static DateTime checkOutMensal(DateTime checkIn, int meses) {
    var data = dateOnly(checkIn);
    for (var i = 0; i < meses; i++) {
      data = addMonthNoOverflow(data);
    }
    return data;
  }

  static int diarias(DateTime checkIn, DateTime checkOut) {
    final a = DateTime.utc(checkIn.year, checkIn.month, checkIn.day);
    final b = DateTime.utc(checkOut.year, checkOut.month, checkOut.day);
    return b.difference(a).inDays;
  }

  /// Quantidade de diárias ou de meses. Retorna null se o período é inválido
  /// (por exemplo, mensal que não fecha meses completos).
  static int? unidades(String modalidade, DateTime checkIn, DateTime checkOut) {
    final ci = dateOnly(checkIn);
    final co = dateOnly(checkOut);
    if (!co.isAfter(ci)) return null;

    if (modalidade == 'mensal') {
      var data = ci;
      var meses = 0;
      while (data.isBefore(co)) {
        data = addMonthNoOverflow(data);
        meses++;
      }
      return data == co ? meses : null;
    }

    return diarias(ci, co);
  }

  static double total({
    required double preco,
    required String modalidade,
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    final qtd = unidades(modalidade, checkIn, checkOut);
    return qtd == null ? 0 : preco * qtd;
  }

  static String formatarMoeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'R\$ $inteiro,${partes[1]}';
  }

  static String formatarData(DateTime? d) {
    if (d == null) return 'Não informada';
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year}';
  }

  /// yyyy-MM-dd, formato esperado pelo Laravel.
  static String dataApi(DateTime d) {
    final ano = d.year.toString().padLeft(4, '0');
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }
}
