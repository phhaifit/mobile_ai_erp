import 'package:mobile_ai_erp/domain/entity/cart/cart_exception.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  int quantity;
  final String? imageUrl;
  final int? stockAvailable;
  final String? category;
  final String? sku;
  final String? selectedSize;
  final String? selectedColor;
  final Map<String, dynamic>? customAttributes;
  final DateTime dateAdded;
  final double? itemDiscount;
  final String? promotionCode;
  bool isSelected;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.stockAvailable,
    this.category,
    this.sku,
    this.selectedSize,
    this.selectedColor,
    this.customAttributes,
    DateTime? dateAdded,
    this.itemDiscount,
    this.promotionCode,
    this.isSelected = false,
  }) : dateAdded = dateAdded ?? DateTime.now() {
    _validateQuantity();
  }

  void _validateQuantity() {
    if (quantity <= 0) {
      throw InvalidCartItemException(
          message: 'Quantity must be greater than 0');
    }

    if (stockAvailable != null && quantity > stockAvailable!) {
      throw InsufficientStockException(
        requestedQuantity: quantity,
        availableQuantity: stockAvailable!,
      );
    }
  }

  double get subtotal => unitPrice * quantity;

  double get itemDiscountAmount {
    if (itemDiscount == null) return 0;
    return (subtotal * itemDiscount!) / 100;
  }

  double get totalBeforeCartDiscount => subtotal - itemDiscountAmount;

  bool get isLowStock {
    if (stockAvailable == null) return false;
    return stockAvailable! < 5;
  }

  bool get isOutOfStock {
    if (stockAvailable == null) return false;
    return stockAvailable! <= 0;
  }

  bool get hasCustomization {
    return selectedSize != null ||
        selectedColor != null ||
        (customAttributes?.isNotEmpty ?? false);
  }

  /// Update quantity with validation
  /// Throws [InvalidCartItemException] if quantity is invalid
  /// Throws [InsufficientStockException] if quantity exceeds stock
  void updateQuantity(int newQuantity) {
    if (newQuantity <= 0) {
      throw InvalidCartItemException(
          message: 'Quantity must be greater than 0');
    }

    if (stockAvailable != null && newQuantity > stockAvailable!) {
      throw InsufficientStockException(
        requestedQuantity: newQuantity,
        availableQuantity: stockAvailable!,
      );
    }

    quantity = newQuantity;
  }

  /// Increment quantity by 1
  /// Throws [InsufficientStockException] if incrementing exceeds stock
  void incrementQuantity() {
    updateQuantity(quantity + 1);
  }

  /// Decrement quantity by 1
  /// Throws [InvalidCartItemException] if quantity becomes 0
  void decrementQuantity() {
    if (quantity <= 1) {
      throw InvalidCartItemException(
        message: 'Cannot decrement below 1. Please remove item from cart.',
      );
    }
    updateQuantity(quantity - 1);
  }

  /// Create a copy with modified fields
  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    String? imageUrl,
    int? stockAvailable,
    String? category,
    String? sku,
    String? selectedSize,
    String? selectedColor,
    Map<String, dynamic>? customAttributes,
    DateTime? dateAdded,
    double? itemDiscount,
    String? promotionCode,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      customAttributes: customAttributes ?? this.customAttributes,
      dateAdded: dateAdded ?? this.dateAdded,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      promotionCode: promotionCode ?? this.promotionCode,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() =>
      'CartItem(id: $id, productName: $productName, qty: $quantity, subtotal: ${subtotal.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
