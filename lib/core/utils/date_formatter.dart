import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }
}
