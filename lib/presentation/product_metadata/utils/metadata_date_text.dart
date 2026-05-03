import 'package:mobile_ai_erp/core/utils/date_formatter.dart';

String metadataDateText(DateTime? value) {
  return value == null ? 'Not set' : DateFormatter.formatFull(value);
}
