class ProductSupplierLinkDto {
  final String productId;
  final String productName;
  final String? productSku;
  final String? productBarcode;
  final String supplierId;
  final String? supplierSku;
  final double? costPrice;
  final bool isPrimary;

  ProductSupplierLinkDto({
    required this.productId,
    required this.productName,
    this.productSku,
    this.productBarcode,
    required this.supplierId,
    this.supplierSku,
    this.costPrice,
    required this.isPrimary,
  });

  factory ProductSupplierLinkDto.fromJson(Map<String, dynamic> json) {
    return ProductSupplierLinkDto(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['sku'] as String?,
      productBarcode: json['barcode'] as String?,
      supplierId: json['supplierId'] as String,
      supplierSku: json['supplierSku'] as String?,
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class AddProductSupplierRequestDto {
  final String supplierId;
  final String? supplierSku;
  final double? costPrice;
  final bool isPrimary;

  const AddProductSupplierRequestDto({
    required this.supplierId,
    this.supplierSku,
    this.costPrice,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      // Omit empty strings — empty supplierSku is meaningless for a new link
      if (supplierSku?.isNotEmpty == true) 'supplierSku': supplierSku,
      if (costPrice != null) 'costPrice': costPrice,
      'isPrimary': isPrimary,
    };
  }
}

class UpdateProductSupplierRequestDto {
  final String? supplierSku;
  final double? costPrice;
  final bool? isPrimary;

  const UpdateProductSupplierRequestDto({
    this.supplierSku,
    this.costPrice,
    this.isPrimary,
  });

  Map<String, dynamic> toJson() {
    return {
      // null is intentionally included to allow clearing the field via PATCH
      if (supplierSku != null) 'supplierSku': supplierSku,
      if (costPrice != null) 'costPrice': costPrice,
      if (isPrimary != null) 'isPrimary': isPrimary,
    };
  }
}
