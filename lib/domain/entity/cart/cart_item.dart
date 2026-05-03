class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String? variantId;
  final int quantity;
  final String unitPrice;
  final String? originalPrice;
  final String lineTotal;
  final DateTime addedAt;

  final String productName;
  final String sku;
  final String productType;
  final String productStatus;
  final String? thumbnailUrl;
  final String? variantSummary;
  final List<CartItemAttribute> attributes;
  final int availableStock;
  final bool isPriceChanged;
  final bool isAvailable;
  final bool stockWarning;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.originalPrice,
    required this.lineTotal,
    required this.addedAt,
    required this.productName,
    required this.sku,
    required this.productType,
    required this.productStatus,
    required this.thumbnailUrl,
    required this.variantSummary,
    required this.attributes,
    required this.availableStock,
    required this.isPriceChanged,
    required this.isAvailable,
    required this.stockWarning,
  });

  CartItem copyWith({
    String? id,
    String? cartId,
    String? productId,
    String? variantId,
    int? quantity,
    String? unitPrice,
    String? originalPrice,
    String? lineTotal,
    DateTime? addedAt,
    String? productName,
    String? sku,
    String? productType,
    String? productStatus,
    String? thumbnailUrl,
    String? variantSummary,
    List<CartItemAttribute>? attributes,
    int? availableStock,
    bool? isPriceChanged,
    bool? isAvailable,
    bool? stockWarning,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      addedAt: addedAt ?? this.addedAt,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      productType: productType ?? this.productType,
      productStatus: productStatus ?? this.productStatus,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      variantSummary: variantSummary ?? this.variantSummary,
      attributes: attributes ?? this.attributes,
      availableStock: availableStock ?? this.availableStock,
      isPriceChanged: isPriceChanged ?? this.isPriceChanged,
      isAvailable: isAvailable ?? this.isAvailable,
      stockWarning: stockWarning ?? this.stockWarning,
    );
  }
}

class CartItemAttribute {
  final String label;
  final String value;

  const CartItemAttribute({required this.label, required this.value});
}
