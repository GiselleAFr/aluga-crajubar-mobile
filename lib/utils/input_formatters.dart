import 'package:flutter/services.dart';

class DigitsMaskInputFormatter extends TextInputFormatter {
  const DigitsMaskInputFormatter({
    required this.maxDigits,
    required this.formatDigits,
  });

  final int maxDigits;
  final String Function(String digits) formatDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final selectionOffset = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );
    final digitsBeforeCursor = newValue.text
        .substring(0, selectionOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final formatted = formatDigits(limitedDigits);
    final cursorDigitCount = digitsBeforeCursor.clamp(0, limitedDigits.length);
    var cursorOffset = 0;
    var seenDigits = 0;

    while (cursorOffset < formatted.length && seenDigits < cursorDigitCount) {
      if (RegExp(r'\d').hasMatch(formatted[cursorOffset])) {
        seenDigits++;
      }
      cursorOffset++;
    }

    while (cursorOffset < formatted.length &&
        !RegExp(r'\d').hasMatch(formatted[cursorOffset])) {
      cursorOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}

String formatCpfDigits(String digits) {
  if (digits.length <= 3) return digits;
  if (digits.length <= 6) {
    return '${digits.substring(0, 3)}.${digits.substring(3)}';
  }
  if (digits.length <= 9) {
    return '${digits.substring(0, 3)}.'
        '${digits.substring(3, 6)}.${digits.substring(6)}';
  }
  return '${digits.substring(0, 3)}.'
      '${digits.substring(3, 6)}.${digits.substring(6, 9)}-'
      '${digits.substring(9)}';
}

String formatBrazilianPhoneDigits(String digits) {
  if (digits.length <= 2) {
    return digits.length == 2 ? '($digits)' : '($digits';
  }

  final areaCode = digits.substring(0, 2);
  final subscriber = digits.substring(2);
  if (subscriber.length <= 4) return '($areaCode) $subscriber';

  final splitAt = subscriber.length - 4;
  return '($areaCode) ${subscriber.substring(0, splitAt)}-'
      '${subscriber.substring(splitAt)}';
}

String formatDateDigits(String digits) {
  if (digits.length <= 2) return digits;
  if (digits.length <= 4) {
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }
  return '${digits.substring(0, 2)}/${digits.substring(2, 4)}/'
      '${digits.substring(4)}';
}
