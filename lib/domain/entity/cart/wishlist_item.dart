class WishlistItem {
  final String id;
  final String wishlistId;
  final String productId;
  final String? variantId;
  final DateTime addedAt;

  final String productName;
  final String sku;
  final String productType;
  final String productStatus;
  final String sellingPrice;
  final String? originalPrice;
  final String? thumbnailUrl;
  final String? variantSummary;
  final List<WishlistItemAttribute> attributes;
  final bool isAvailable;

  const WishlistItem({
    required this.id,
    required this.wishlistId,
    required this.productId,
    required this.variantId,
    required this.addedAt,
    required this.productName,
    required this.sku,
    required this.productType,
    required this.productStatus,
    required this.sellingPrice,
    required this.originalPrice,
    required this.thumbnailUrl,
    required this.variantSummary,
    required this.attributes,
    required this.isAvailable,
  });

  WishlistItem copyWith({
    String? id,
    String? wishlistId,
    String? productId,
    String? variantId,
    DateTime? addedAt,
    String? productName,
    String? sku,
    String? productType,
    String? productStatus,
    String? sellingPrice,
    String? originalPrice,
    String? thumbnailUrl,
    String? variantSummary,
    List<WishlistItemAttribute>? attributes,
    bool? isAvailable,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      wishlistId: wishlistId ?? this.wishlistId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      addedAt: addedAt ?? this.addedAt,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      productType: productType ?? this.productType,
      productStatus: productStatus ?? this.productStatus,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      variantSummary: variantSummary ?? this.variantSummary,
      attributes: attributes ?? this.attributes,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class WishlistItemAttribute {
  final String label;
  final String value;

  const WishlistItemAttribute({required this.label, required this.value});
}
