class BrandImage {
  const BrandImage({
    required this.brandId,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  final String brandId;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;
}
