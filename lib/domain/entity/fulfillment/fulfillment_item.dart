class FulfillmentItem {
  final String id;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? productId;
  final String? variantId;

  const FulfillmentItem({
    required this.id,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.productId,
    this.variantId,
  });

  FulfillmentItem copyWith({
    String? id,
    String? productName,
    String? sku,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? productId,
    String? variantId,
  }) {
    return FulfillmentItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
    );
  }
}
