import 'product_summary_supplier_ref.dart';

class ProductSummary {
  final String id;
  final String sku;
  final String name;
  final String? barcode;
  final String? description;
  final String? brandName;
  final String? categoryName;
  final double? basePrice;
  final double? sellingPrice;
  final String? imageUrl;
  final List<ProductSummarySupplierRef> suppliers;

  const ProductSummary({
    required this.id,
    required this.sku,
    required this.name,
    this.barcode,
    this.description,
    this.brandName,
    this.categoryName,
    this.basePrice,
    this.sellingPrice,
    this.imageUrl,
    this.suppliers = const [],
  });

  bool isLinkedToSupplier(String supplierId) {
    return suppliers.any((supplier) => supplier.supplierId == supplierId);
  }
}
