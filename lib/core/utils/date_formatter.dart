import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _fullDate = DateFormat('dd MMM yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _shortDate = DateFormat('dd/MM/yyyy');

  static String formatFull(DateTime date) => _fullDate.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);
  static String formatShort(DateTime date) => _shortDate.format(date);

  static String formatCurrency(double amount) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
}
