/// Wishlist item entity - product saved for later purchase from cart
class WishlistItem {
  /// Unique identifier for this wishlist item
  final String id;

  /// Product ID reference
  final String productId;

  /// Product name
  final String productName;

  /// Product price
  final double price;

  /// Product image URL
  final String? imageUrl;

  /// Product category
  final String? category;

  /// Stock available for this product
  final int? stockAvailable;

  /// Date when item was added to wishlist
  final DateTime dateAdded;

  /// Last time item was viewed/modified
  final DateTime? lastViewed;

  /// Notes or tags for this wishlist item (e.g., "gift for mom", "need XXL size")
  final String? notes;

  /// Priority level (1-5, where 5 is highest priority)
  final int? priority;

  /// Whether this product is on sale
  final bool isOnSale;

  /// Sale price if product is on sale
  final double? salePrice;

  /// Product rating (0-5 stars)
  final double? rating;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    this.category,
    this.stockAvailable,
    required this.dateAdded,
    this.lastViewed,
    this.notes,
    this.priority,
    this.isOnSale = false,
    this.salePrice,
    this.rating,
  });

  /// Get effective price (sale price if on sale, otherwise regular price)
  double get effectivePrice =>
      isOnSale && salePrice != null ? salePrice! : price;

  /// Calculate savings amount if on sale
  double? get savingsAmount {
    if (isOnSale && salePrice != null) {
      return price - salePrice!;
    }
    return null;
  }

  /// Calculate savings percentage if on sale
  double? get savingsPercentage {
    if (isOnSale && salePrice != null) {
      return ((price - salePrice!) / price) * 100;
    }
    return null;
  }

  /// Check if product has low stock
  bool get isLowStock {
    if (stockAvailable == null) return false;
    return stockAvailable! < 5; // Low stock if less than 5 items
  }

  /// Check if product is out of stock
  bool get isOutOfStock {
    if (stockAvailable == null) return false;
    return stockAvailable! <= 0;
  }

  /// Get time span since item was added (e.g., "2 days ago")
  String get timeSpanSinceAdded {
    final duration = DateTime.now().difference(dateAdded);

    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create a copy with modified fields
  WishlistItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    String? category,
    int? stockAvailable,
    DateTime? dateAdded,
    DateTime? lastViewed,
    String? notes,
    int? priority,
    bool? isOnSale,
    double? salePrice,
    double? rating,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      dateAdded: dateAdded ?? this.dateAdded,
      lastViewed: lastViewed ?? this.lastViewed,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      isOnSale: isOnSale ?? this.isOnSale,
      salePrice: salePrice ?? this.salePrice,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() =>
      'WishlistItem(id: $id, productName: $productName, price: $effectivePrice)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
