class ProductMetadataValidationException implements Exception {
  const ProductMetadataValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
