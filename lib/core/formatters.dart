import 'package:intl/intl.dart';

import 'constants.dart';

class Fmt {
  Fmt._();

  static final NumberFormat _money =
      NumberFormat.currency(symbol: kCurrencySymbol, decimalDigits: 2);
  static final DateFormat _short = DateFormat('dd MMM yyyy');
  static final DateFormat _full = DateFormat('EEEE, dd MMMM yyyy');
  static final DateFormat _today = DateFormat('EEEE, d MMMM');

  static String money(double value) => _money.format(value);

  static String date(DateTime value) => _short.format(value);

  static String fullDate(DateTime value) => _full.format(value);

  static String todayLabel() => _today.format(DateTime.now());
}