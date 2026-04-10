class SupplierProductLink {
  final String supplierId;
  final String productId;
  final String productName;
  final String supplierSku;
  final double? costPrice;
  final bool isPrimary;

  const SupplierProductLink({
    required this.supplierId,
    required this.productId,
    required this.productName,
    this.supplierSku = '',
    this.costPrice,
    this.isPrimary = false,
  });

  SupplierProductLink copyWith({
    String? supplierId,
    String? productId,
    String? productName,
    String? supplierSku,
    double? costPrice,
    bool? isPrimary,
  }) {
    return SupplierProductLink(
      supplierId: supplierId ?? this.supplierId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      supplierSku: supplierSku ?? this.supplierSku,
      costPrice: costPrice ?? this.costPrice,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
