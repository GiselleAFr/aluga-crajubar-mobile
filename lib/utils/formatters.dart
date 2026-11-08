/// Formata telefones brasileiros: +55 (88) 99999-9999.
/// Se o formato não for reconhecido, devolve o texto original.
String formatarTelefone(String? bruto) {
  final texto = bruto?.trim() ?? '';
  final d = texto.replaceAll(RegExp(r'\D'), '');

  if (d.length == 13 && d.startsWith('55')) {
    return '+55 (${d.substring(2, 4)}) ${d.substring(4, 9)}-${d.substring(9)}';
  }
  if (d.length == 12 && d.startsWith('55')) {
    return '+55 (${d.substring(2, 4)}) ${d.substring(4, 8)}-${d.substring(8)}';
  }
  if (d.length == 11) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
  }
  if (d.length == 10) {
    return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
  }
  return texto;
}

/// Ex.: 8 de novembro de 2026.
String dataPorExtenso(DateTime data) {
  const meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
}