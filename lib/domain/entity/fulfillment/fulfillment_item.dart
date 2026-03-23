class FulfillmentItem {
  final String id;
  final String productName;
  final String sku;
  final int quantity;
  final int pickedQuantity;
  final int packedQuantity;
  final int shippedQuantity;
  final double unitPrice;

  const FulfillmentItem({
    required this.id,
    required this.productName,
    required this.sku,
    required this.quantity,
    this.pickedQuantity = 0,
    this.packedQuantity = 0,
    this.shippedQuantity = 0,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  bool get isFullyPicked => pickedQuantity >= quantity;
  bool get isFullyPacked => packedQuantity >= quantity;
  bool get isFullyShipped => shippedQuantity >= quantity;

  FulfillmentItem copyWith({
    String? id,
    String? productName,
    String? sku,
    int? quantity,
    int? pickedQuantity,
    int? packedQuantity,
    int? shippedQuantity,
    double? unitPrice,
  }) {
    return FulfillmentItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      pickedQuantity: pickedQuantity ?? this.pickedQuantity,
      packedQuantity: packedQuantity ?? this.packedQuantity,
      shippedQuantity: shippedQuantity ?? this.shippedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
