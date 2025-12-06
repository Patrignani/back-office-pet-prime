import 'package:flutter/services.dart';
import 'dart:math';

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    final value = double.parse(digits) / 100.0;

    final formatted = _formatReal(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatReal(double value) {
    String digits = value.toStringAsFixed(2);
    List<String> parts = digits.split('.');
    String integer = parts[0];
    String decimal = parts[1];

    String formattedInt = '';
    for (int i = 0; i < integer.length; i++) {
      int position = integer.length - i;
      formattedInt += integer[i];
      if (position > 1 && position % 3 == 1) {
        formattedInt += '.';
      }
    }
    return '$formattedInt,$decimal';
  }
}
