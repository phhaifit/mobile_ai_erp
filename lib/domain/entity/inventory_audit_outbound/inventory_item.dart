class InventoryItem {
  final String warehouseId;
  final String productId;
  final String productName;
  final int systemQty;
  final String unit;

  const InventoryItem({
    required this.warehouseId,
    required this.productId,
    required this.productName,
    required this.systemQty,
    this.unit = 'pcs',
  });

  InventoryItem copyWith({
    String? warehouseId,
    String? productId,
    String? productName,
    int? systemQty,
    String? unit,
  }) {
    return InventoryItem(
      warehouseId: warehouseId ?? this.warehouseId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      systemQty: systemQty ?? this.systemQty,
      unit: unit ?? this.unit,
    );
  }
}
