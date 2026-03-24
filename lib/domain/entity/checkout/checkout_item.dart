/// Represents an item in the checkout order
class CheckoutItem {
  const CheckoutItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
    this.variantInfo,
    this.weight,
    this.discount = 0.0,
  });

  /// Unique identifier for this checkout item
  final String id;

  /// Product ID reference
  final String productId;

  /// Product name
  final String productName;

  /// Stock keeping unit
  final String sku;

  /// Quantity being purchased
  final int quantity;

  /// Price per unit
  final double unitPrice;

  /// Product image URL
  final String? imageUrl;

  /// Variant information (color, size, etc.)
  final Map<String, String>? variantInfo;

  /// Weight in kg (for shipping calculation)
  final double? weight;

  /// Discount applied to this item
  final double discount;

  /// Get total price for this item (before discount)
  double get totalPrice => quantity * unitPrice;

  /// Get total price after discount
  double get finalPrice => totalPrice - discount;

  /// Get formatted variant string
  String get variantString {
    if (variantInfo == null || variantInfo!.isEmpty) return '';
    return variantInfo!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  /// Get total weight for this item
  double get totalWeight => (weight ?? 0) * quantity;

  CheckoutItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    int? quantity,
    double? unitPrice,
    String? imageUrl,
    Map<String, String>? variantInfo,
    double? weight,
    double? discount,
  }) {
    return CheckoutItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      variantInfo: variantInfo ?? this.variantInfo,
      weight: weight ?? this.weight,
      discount: discount ?? this.discount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
