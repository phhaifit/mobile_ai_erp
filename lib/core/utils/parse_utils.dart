/// Parses a dynamic value to double.
///
/// Handles null, double, int, and String types.
/// Returns 0.0 for unparseable or null values.
double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
