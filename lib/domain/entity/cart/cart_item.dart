import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_exception.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class CartItem {
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

  /// Cart state
  final int quantity;
  final bool isSelected;
  final DateTime dateAdded;

  CartItem({
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
    this.isSelected = false,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now() {
    _validateQuantity(quantity);
  }

  /// Factory: create cart item directly from ProductVariant
  factory CartItem.fromVariant({
    required String productId,
    required String productName,
    required ProductVariant variant,
    String? imageUrl,
    int quantity = 1,
  }) {
    return CartItem(
      id: '${productId}_${variant.id}',
      productId: productId,
      productName: productName,
      imageUrl: imageUrl,
      variantId: variant.id,
      sku: variant.sku,
      selectedSize: variant.size,
      selectedColorName: variant.color?.name,
      selectedColorValue: variant.color?.color,
      price: variant.price,
      salePrice: variant.salePrice,
      stockAvailable: variant.stockQuantity,
      quantity: quantity,
    );
  }

  void _validateQuantity(int value) {
    if (value <= 0) {
      throw InvalidCartItemException(
        message: 'Quantity must be greater than 0',
      );
    }

    if (stockAvailable != null && value > stockAvailable!) {
      throw InsufficientStockException(
        requestedQuantity: value,
        availableQuantity: stockAvailable!,
      );
    }
  }

  /// Base price before discount
  double get originalUnitPrice => price;

  /// Actual price user pays
  double get effectivePrice => salePrice ?? price;

  /// Has variant sale
  bool get hasDiscount => salePrice != null && salePrice! < price;

  /// Discount percentage of this variant
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  /// Total before variant discount
  double get subtotalBeforeDiscount => originalUnitPrice * quantity;

  /// Total variant discount amount
  double get variantDiscountAmount =>
      (originalUnitPrice - effectivePrice) * quantity;

  /// Actual subtotal after variant discount
  double get subtotal => effectivePrice * quantity;

  /// Keep compatibility with existing Cart.subtotal logic
  double get totalBeforeCartDiscount => subtotal;

  bool get isLowStock {
    if (stockAvailable == null) return false;
    return stockAvailable! > 0 && stockAvailable! <= 5;
  }

  bool get isOutOfStock {
    if (stockAvailable == null) return false;
    return stockAvailable! <= 0;
  }

  bool get hasCustomization =>
      selectedSize != null || selectedColorName != null;

  /// Update quantity immutably with validation
  CartItem updateQuantity(int newQuantity) {
    _validateQuantity(newQuantity);
    return copyWith(quantity: newQuantity);
  }

  /// Increment quantity by 1
  CartItem incrementQuantity() {
    return updateQuantity(quantity + 1);
  }

  /// Decrement quantity by 1
  CartItem decrementQuantity() {
    if (quantity <= 1) {
      throw InvalidCartItemException(
        message: 'Cannot decrement below 1. Please remove item from cart.',
      );
    }
    return updateQuantity(quantity - 1);
  }

  CartItem copyWith({
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
    bool? isSelected,
    DateTime? dateAdded,
  }) {
    return CartItem(
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
      isSelected: isSelected ?? this.isSelected,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() =>
      'CartItem(id: $id, productName: $productName, variantId: $variantId, qty: $quantity, subtotal: ${subtotal.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          variantId == other.variantId;

  @override
  int get hashCode => Object.hash(id, variantId);
}
