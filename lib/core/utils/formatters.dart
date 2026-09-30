import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormatter = NumberFormat.decimalPattern();

  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  /// Format double to currency string e.g. $1,250.50
  static String currency(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Format integer with commas e.g. 1,200
  static String number(int count) {
    return _numberFormatter.format(count);
  }

  /// Format DateTime to short date string e.g. Sep 30, 2026
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format DateTime to time string e.g. 02:45 PM
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format DateTime to date + time string
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
}
