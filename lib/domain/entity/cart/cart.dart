import 'package:mobile_ai_erp/domain/entity/cart/cart_exception.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Coupon? appliedCoupon;
  final String? deliveryAddressId;
  final String? shippingMethod;
  final double? shippingCost;
  final double? taxPercentage;
  final String? notes;
  final DateTime dateCreated;
  final DateTime dateModified;
  final DateTime? dateSynced;
  final bool isAbandoned;
  final DateTime? abandonedDate;
  final String status; // 'active', 'abandoned', 'converted', 'expired'

  Cart({
    required this.id,
    required this.userId,
    this.items = const [],
    this.appliedCoupon,
    this.deliveryAddressId,
    this.shippingMethod,
    this.shippingCost,
    this.taxPercentage,
    this.notes,
    DateTime? dateCreated,
    DateTime? dateModified,
    this.dateSynced,
    this.isAbandoned = false,
    this.abandonedDate,
    this.status = 'active',
  })  : dateCreated = dateCreated ?? DateTime.now(),
        dateModified = dateModified ?? DateTime.now();

  /// Get total number of items (quantity sum)
  int get itemCount =>
      items.isEmpty ? 0 : items.fold(0, (sum, item) => sum + item.quantity);

  /// Get total number of products (count of unique items)
  int get uniqueItemCount => items.length;

  /// Get cart subtotal (before any discounts but after item-level discounts)
  double get subtotal => items.isEmpty
      ? 0
      : items.fold(0, (sum, item) => sum + item.totalBeforeCartDiscount);

  /// Get cart-level discount amount (from coupon)
  double get cartLevelDiscount {
    if (appliedCoupon == null) return 0;

    try {
      return appliedCoupon!.calculateDiscount(subtotal);
    } catch (e) {
      // If coupon is invalid, return 0
      return 0;
    }
  }

  /// Get total tax amount
  double get taxAmount {
    if (taxPercentage == null || taxPercentage == 0) return 0;
    return ((subtotal - cartLevelDiscount) * taxPercentage!) / 100;
  }

  /// Get shipping cost
  double get shippingAmount => shippingCost ?? 0;

  /// Get total cart value (subtotal - coupon discount + tax + shipping)
  double get total => subtotal - cartLevelDiscount + taxAmount + shippingAmount;

  /// Get savings amount (total before any discounts, minus total)
  double get savingsAmount => (subtotal + taxAmount + shippingAmount) - total;

  /// Get savings percentage
  double get savingsPercentage {
    double baseTotal = subtotal + taxAmount + shippingAmount;
    if (baseTotal == 0) return 0;
    return (savingsAmount / baseTotal) * 100;
  }

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if any item has low stock
  bool get hasLowStockItems => items.any((item) => item.isLowStock);

  /// Check if any item is out of stock
  bool get hasOutOfStockItems => items.any((item) => item.isOutOfStock);

  /// Get list of out of stock items
  List<CartItem> get outOfStockItems =>
      items.where((item) => item.isOutOfStock).toList();

  /// Get list of low stock items
  List<CartItem> get lowStockItems =>
      items.where((item) => item.isLowStock).toList();

  /// Check if coupon is currently applied
  bool get hasCoupon => appliedCoupon != null;

  /// Check if coupon is valid
  bool get isCouponValid => appliedCoupon?.isValid ?? false;

  /// Get selected/checked items count
  int get selectedItemsCount => items.where((item) => item.isSelected).length;

  /// Add item to cart or increment quantity if item already exists
  /// Throws [DuplicateCartItemException] if item with same customization already exists
  Cart addItem(CartItem newItem) {
    if (isEmpty) {
      return _createModifiedCart([newItem]);
    }

    // Check if item already exists with same customization
    final existingItemIndex = items.indexWhere(
      (item) =>
          item.productId == newItem.productId &&
          item.variantId == newItem.variantId,
    );

    if (existingItemIndex != -1) {
      // Item exists, increment quantity
      final updatedItem = items[existingItemIndex].copyWith(
        quantity: items[existingItemIndex].quantity + newItem.quantity,
      );

      final updatedItems = [...items];
      updatedItems[existingItemIndex] = updatedItem;

      return _createModifiedCart(updatedItems);
    }

    // New item with different customization
    return _createModifiedCart([...items, newItem]);
  }

  /// Remove item from cart by ID
  /// Throws [CartItemNotFoundException] if item not found
  Cart removeItem(String itemId) {
    final itemExists = items.any((item) => item.id == itemId);
    if (!itemExists) {
      throw CartItemNotFoundException(itemId: itemId);
    }

    final updatedItems = items.where((item) => item.id != itemId).toList();
    return _createModifiedCart(updatedItems);
  }

  /// Update item quantity
  /// Throws [CartItemNotFoundException] if item not found
  Cart updateItemQuantity(String itemId, int newQuantity) {
    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      throw CartItemNotFoundException(itemId: itemId);
    }

    final updatedItem = items[itemIndex].copyWith(quantity: newQuantity);
    final updatedItems = [...items];
    updatedItems[itemIndex] = updatedItem;

    return _createModifiedCart(updatedItems);
  }

  /// Increment item quantity
  Cart incrementItemQuantity(String itemId) {
    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      throw CartItemNotFoundException(itemId: itemId);
    }

    final currentQty = items[itemIndex].quantity;
    return updateItemQuantity(itemId, currentQty + 1);
  }

  /// Decrement item quantity
  Cart decrementItemQuantity(String itemId) {
    final itemIndex = items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      throw CartItemNotFoundException(itemId: itemId);
    }

    final currentQty = items[itemIndex].quantity;
    if (currentQty <= 1) {
      return removeItem(itemId);
    }

    return updateItemQuantity(itemId, currentQty - 1);
  }

  /// Apply coupon code
  /// Throws [InvalidCouponException] if coupon is invalid
  Cart applyCoupon(Coupon coupon) {
    if (!coupon.isValid) {
      throw InvalidCouponException(couponCode: coupon.code);
    }

    // Validate minimum cart value
    if (coupon.minCartValue != null && subtotal < coupon.minCartValue!) {
      throw CouponMinimumValueException(
        minValue: coupon.minCartValue!,
        currentValue: subtotal,
        couponCode: coupon.code,
      );
    }

    return _createModifiedCart(items, coupon: coupon);
  }

  /// Remove applied coupon
  Cart removeCoupon() {
    return _createModifiedCart(items, coupon: null);
  }

  /// Clear all items from cart
  Cart clear() {
    return _createModifiedCart([]);
  }

  /// Remove all selected items
  Cart removeSelectedItems() {
    final unselectedItems = items.where((item) => !item.isSelected).toList();
    return _createModifiedCart(unselectedItems);
  }

  /// Validate cart before checkout
  /// Returns list of validation errors (empty list means valid)
  List<String> validate() {
    final errors = <String>[];

    if (isEmpty) {
      errors.add('Cart is empty');
    }

    if (hasOutOfStockItems) {
      final outOfStockNames =
          outOfStockItems.map((e) => e.productName).join(', ');
      errors.add('Out of stock items: $outOfStockNames');
    }

    if (!isCouponValid) {
      errors.add('Applied coupon is no longer valid');
    }

    return errors;
  }

  /// Create modified cart copy with new state
  Cart _createModifiedCart(
    List<CartItem> newItems, {
    Coupon? coupon,
  }) {
    return Cart(
      id: id,
      userId: userId,
      items: newItems,
      appliedCoupon: coupon ?? appliedCoupon,
      deliveryAddressId: deliveryAddressId,
      shippingMethod: shippingMethod,
      shippingCost: shippingCost,
      taxPercentage: taxPercentage,
      notes: notes,
      dateCreated: dateCreated,
      dateModified: DateTime.now(),
      dateSynced: dateSynced,
      isAbandoned: isAbandoned,
      abandonedDate: abandonedDate,
      status: status,
    );
  }

  /// Create a copy with modified fields
  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    Coupon? appliedCoupon,
    String? deliveryAddressId,
    String? shippingMethod,
    double? shippingCost,
    double? taxPercentage,
    String? notes,
    DateTime? dateCreated,
    DateTime? dateModified,
    DateTime? dateSynced,
    bool? isAbandoned,
    DateTime? abandonedDate,
    String? status,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      shippingCost: shippingCost ?? this.shippingCost,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      notes: notes ?? this.notes,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      dateSynced: dateSynced ?? this.dateSynced,
      isAbandoned: isAbandoned ?? this.isAbandoned,
      abandonedDate: abandonedDate ?? this.abandonedDate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'Cart(id: $id, items: ${items.length}, total: ${total.toStringAsFixed(2)}, coupon: ${appliedCoupon?.code})';

  String? get appliedCouponCode => appliedCoupon?.code;
}
