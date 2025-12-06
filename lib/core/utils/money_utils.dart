double parseMoney(String v) {
  final clean = v.replaceAll('.', '').replaceAll(',', '.');
  return double.parse(clean);
}

String formatMoneyToInput(double value) {
  return value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
}
