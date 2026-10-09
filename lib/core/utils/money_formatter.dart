class MoneyFormatter {
  const MoneyFormatter._();

  static String rupiah(num? value) {
    if (value == null) return 'Harga belum tersedia';
    final text = value.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final position = text.length - i;
      buffer.write(text[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }
}
