class ProductSummarySupplierRef {
  final String supplierId;
  final String? supplierSku;
  final bool isPrimary;

  const ProductSummarySupplierRef({
    required this.supplierId,
    this.supplierSku,
    this.isPrimary = false,
  });
}
