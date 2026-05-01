class ProductSummarySupplierRefDto {
  final String supplierId;
  final String? supplierSku;
  final bool isPrimary;

  ProductSummarySupplierRefDto({
    required this.supplierId,
    this.supplierSku,
    this.isPrimary = false,
  });

  factory ProductSummarySupplierRefDto.fromJson(Map<String, dynamic> json) {
    return ProductSummarySupplierRefDto(
      supplierId: json['supplierId'] as String,
      supplierSku: json['supplierSku'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class ProductSummaryDto {
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
  final List<ProductSummarySupplierRefDto> suppliers;

  ProductSummaryDto({
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

  factory ProductSummaryDto.fromJson(Map<String, dynamic> json) {
    return ProductSummaryDto(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      brandName: json['brandName'] as String?,
      categoryName: json['categoryName'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      suppliers: (json['suppliers'] as List<dynamic>? ?? [])
          .map(
            (item) => ProductSummarySupplierRefDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
