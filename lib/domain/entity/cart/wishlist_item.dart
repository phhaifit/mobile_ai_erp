import 'package:flutter/material.dart';

class WishlistItem {
  final String id;
  final String productId;
  final String productName;
  final String? imageUrl;

  /// Reference to selected variant
  final String variantId;
  final String sku;

  /// Variant attributes
  final String? selectedSize;
  final String? selectedColorName;
  final Color? selectedColorValue;

  /// Pricing from variant
  final double price;
  final double? salePrice;

  /// Stock from variant
  final int? stockAvailable;

  /// Wishlist state
  final DateTime dateAdded;
  final DateTime? lastViewed;

  /// Optional UI metadata
  final String? category;
  final String? notes;
  final int? priority;
  final double? rating;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.variantId,
    required this.sku,
    this.selectedSize,
    this.selectedColorName,
    this.selectedColorValue,
    required this.price,
    this.salePrice,
    this.stockAvailable,
    required this.dateAdded,
    this.lastViewed,
    this.category,
    this.notes,
    this.priority,
    this.rating,
  });

  double get effectivePrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  double? get savingsAmount {
    if (!hasDiscount) return null;
    return price - salePrice!;
  }

  bool get isLowStock {
    if (stockAvailable == null) return false;
    return stockAvailable! > 0 && stockAvailable! <= 5;
  }

  bool get isOutOfStock {
    if (stockAvailable == null) return false;
    return stockAvailable! <= 0;
  }

  WishlistItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? imageUrl,
    String? variantId,
    String? sku,
    String? selectedSize,
    String? selectedColorName,
    Color? selectedColorValue,
    double? price,
    double? salePrice,
    int? stockAvailable,
    DateTime? dateAdded,
    DateTime? lastViewed,
    String? category,
    String? notes,
    int? priority,
    double? rating,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      variantId: variantId ?? this.variantId,
      sku: sku ?? this.sku,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColorName: selectedColorName ?? this.selectedColorName,
      selectedColorValue: selectedColorValue ?? this.selectedColorValue,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      dateAdded: dateAdded ?? this.dateAdded,
      lastViewed: lastViewed ?? this.lastViewed,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          variantId == other.variantId;

  @override
  int get hashCode => Object.hash(id, variantId);
}
