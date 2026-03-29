class ProductStock {
  final String id;
  final String productId;
  final String productName;
  final String warehouseId;
  final int availableQuantity;
  final String unit;

  const ProductStock({
    required this.id,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.availableQuantity,
    this.unit = 'pcs',
  });

  ProductStock copyWith({
    String? id,
    String? productId,
    String? productName,
    String? warehouseId,
    int? availableQuantity,
    String? unit,
  }) {
    return ProductStock(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      warehouseId: warehouseId ?? this.warehouseId,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      unit: unit ?? this.unit,
    );
  }
}
