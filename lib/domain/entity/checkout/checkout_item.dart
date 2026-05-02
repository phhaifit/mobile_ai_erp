import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';

/// Represents an item in the checkout order
class CheckoutItem {
  const CheckoutItem({
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
    required this.quantity,
    this.weight,
    this.discount = 0.0,
  });

  /// Unique identifier for this checkout item
  final String id;

  /// Product ID reference
  final String productId;

  /// Product name
  final String productName;

  /// Product image URL
  final String? imageUrl;

  /// Reference to selected variant
  final String variantId;

  /// Stock keeping unit
  final String sku;

  /// Selected size variant
  final String? selectedSize;

  /// Selected color name
  final String? selectedColorName;

  /// Selected color value (for display)
  final Color? selectedColorValue;

  /// Original price before discount
  final double price;

  /// Sale price (if on sale)
  final double? salePrice;

  /// Available stock for this variant
  final int? stockAvailable;

  /// Quantity being purchased
  final int quantity;

  /// Weight in kg (for shipping calculation)
  final double? weight;

  /// Discount applied to this item
  final double discount;

  // ==================== Computed Properties ====================

  /// Actual price user pays (sale price if available, otherwise regular price)
  double get unitPrice => salePrice ?? price;

  /// Check if item has a discount
  bool get hasDiscount => salePrice != null && salePrice! < price;

  /// Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - salePrice!) / price) * 100;
  }

  /// Get total price for this item (before item discount)
  double get subtotal => quantity * unitPrice;

  /// Get total price before any discounts
  double get totalBeforeDiscount => quantity * price;

  /// Get total price after item-level discount
  double get totalAfterDiscount => subtotal - discount;

  /// Get total weight for this item
  double get totalWeight => (weight ?? 0) * quantity;

  /// Get formatted variant string
  String get variantString {
    final parts = <String>[];
    if (selectedSize != null) parts.add('Size: $selectedSize');
    if (selectedColorName != null) parts.add('Color: $selectedColorName');
    return parts.join(', ');
  }

  /// Check if item is in stock
  bool get isInStock => stockAvailable == null || stockAvailable! > 0;

  /// Check if item has low stock (less than 5)
  bool get isLowStock =>
      stockAvailable != null && stockAvailable! > 0 && stockAvailable! <= 5;

  // ==================== Factory Constructors ====================

  /// Create CheckoutItem from CartItem
  factory CheckoutItem.fromCartItem(CartItem cartItem) {
    return CheckoutItem(
      id: cartItem.id,
      productId: cartItem.productId,
      productName: cartItem.productName,
      sku: cartItem.sku,
      imageUrl: cartItem.thumbnailUrl,
      variantId: cartItem.variantId ?? '',
      selectedSize: null,
      selectedColorName: cartItem.variantSummary,
      selectedColorValue: null,
      price: double.tryParse(cartItem.unitPrice) ?? 0,
      salePrice: cartItem.originalPrice != null
          ? double.tryParse(cartItem.originalPrice!)
          : null,
      stockAvailable: cartItem.availableStock,
      quantity: cartItem.quantity,
      weight: null, // CartItem doesn't have weight
    );
  }

  /// Create CheckoutItem from checkout data map (from CartStore.checkoutData)
  factory CheckoutItem.fromCheckoutData(Map<String, dynamic> data) {
    return CheckoutItem(
      id: data['cartItemId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      variantId: data['variantId'] as String? ?? '',
      sku: data['sku'] as String? ?? '',
      selectedSize: data['size'] as String?,
      selectedColorName: data['colorName'] as String?,
      selectedColorValue: null, // Can't deserialize Color
      price: (data['originalUnitPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['unitPrice'] as num?)?.toDouble(),
      stockAvailable: data['availableStock'] as int?,
      quantity: data['quantity'] as int? ?? 1,
    );
  }

  // ==================== Methods ====================

  CheckoutItem copyWith({
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
    int? quantity,
    double? weight,
    double? discount,
  }) {
    return CheckoutItem(
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
      quantity: quantity ?? this.quantity,
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

  @override
  String toString() {
    return 'CheckoutItem(id: $id, productId: $productId, productName: $productName, '
        'variantId: $variantId, sku: $sku, quantity: $quantity, unitPrice: $unitPrice)';
  }
}
