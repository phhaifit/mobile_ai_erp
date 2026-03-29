/// UI Models for Cart Feature
/// Converts domain entities to UI-friendly representations with formatting and computed properties
///
import 'package:mobile_ai_erp/constants/cart_constants.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';

class CartUIModel {
  final String id;
  final String userId;
  final List<CartItemUIModel> items;
  final String? appliedCouponCode;
  final CouponUIModel? appliedCoupon;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastAccessedAt;

  CartUIModel({
    required this.id,
    required this.userId,
    required this.items,
    this.appliedCouponCode,
    this.appliedCoupon,
    required this.createdAt,
    this.updatedAt,
    this.lastAccessedAt,
  });

  /// Factory constructor from domain Cart entity
  factory CartUIModel.fromEntity(Cart cart) {
    return CartUIModel(
      id: cart.id,
      userId: cart.userId,
      items: cart.items
          .map((item) => CartItemUIModel.fromEntity(item))
          .toList(),
      appliedCouponCode: cart.appliedCoupon?.code,
      appliedCoupon: cart.appliedCoupon != null
          ? CouponUIModel.fromEntity(cart.appliedCoupon!)
          : null,
      createdAt: cart.dateCreated,
      updatedAt: cart.dateModified,
      lastAccessedAt: cart.dateSynced,
    );
  }

  /// Cart UI State Properties
  bool get isEmpty => items.isEmpty;
  int get itemCount => items.length;
  int get uniqueItemCount => items.length;
  bool get hasCoupon => appliedCoupon != null;
  bool get hasLowStockItems => items.any((item) => item.isLowStock);
  bool get hasOutOfStockItems => items.any((item) => item.isOutOfStock);

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  double get originalSubtotal => items.fold<double>(
    0,
    (sum, item) => sum + (item.originalPrice * item.quantity),
  );

  double get discountAmount {
    if (appliedCoupon == null) return 0;

    if (!appliedCoupon!.isPercentage) {
      return appliedCoupon!.discountValue;
    }

    final discount = originalSubtotal * (appliedCoupon!.discountValue / 100);

    if (appliedCoupon!.maxDiscount != null) {
      return discount > appliedCoupon!.maxDiscount!
          ? appliedCoupon!.maxDiscount!
          : discount;
    }

    return discount;
  }

  double get taxAmount {
    final taxableAmount = subtotal - discountAmount;
    return taxableAmount * (CartConstants.defaultTaxRate / 100);
  }

  double get shippingAmount {
    if (subtotal >= CartConstants.freeShippingThreshold) return 0;
    return CartConstants.standardShippingCost;
  }

  double get total => subtotal - discountAmount + taxAmount + shippingAmount;

  double get savingsAmount => discountAmount;

  double get savingsPercent =>
      subtotal > 0 ? (discountAmount / subtotal) * 100 : 0;

  /// Formatted Price Strings for Display
  String get formattedSubtotal => PriceFormatter.formatPrice(subtotal);
  String get formattedDiscountAmount =>
      PriceFormatter.formatPrice(discountAmount);
  String get formattedTaxAmount => PriceFormatter.formatPrice(taxAmount);
  String get formattedShippingAmount =>
      PriceFormatter.formatPrice(shippingAmount);
  String get formattedTotal => PriceFormatter.formatPrice(total);
  String get formattedSavingsAmount =>
      PriceFormatter.formatPrice(savingsAmount);
  String get formattedSavingsPercent => '${savingsPercent.toStringAsFixed(0)}%';

  /// Display Properties
  String get shippingLabel {
    if (shippingAmount == 0) {
      return 'Calculated at checkout';
    }
    return 'Shipping: ${PriceFormatter.formatPrice(shippingAmount)}';
  }

  String get cartSummary {
    final buffer = StringBuffer();
    buffer.writeln('Subtotal: $formattedSubtotal');
    if (discountAmount > 0) {
      buffer.writeln('Discount: -$formattedDiscountAmount');
    }
    buffer.writeln('Tax: $formattedTaxAmount');
    buffer.writeln('Shipping: $formattedShippingAmount');
    buffer.write('Total: $formattedTotal');
    return buffer.toString();
  }

  /// Cart Status
  bool get isEligibleForCheckout {
    return !isEmpty && !hasOutOfStockItems;
  }

  String get checkoutStatusMessage {
    if (isEmpty) return 'Your cart is empty';
    if (hasOutOfStockItems) return 'Remove out-of-stock items to proceed';
    if (discountAmount > 0) return 'You\'re saving ${formattedSavingsAmount}!';
    return 'Ready for checkout';
  }

  /// Copy with method for immutable updates
  CartUIModel copyWith({
    String? id,
    String? userId,
    List<CartItemUIModel>? items,
    String? appliedCouponCode,
    CouponUIModel? appliedCoupon,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
  }) {
    return CartUIModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return 'CartUIModel(items: ${items.length}, total: $formattedTotal)';
  }
}

/// Cart Item UI Model
/// Individual item representation with formatting and UI state
class CartItemUIModel {
  final String id;
  final String productId;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int quantity;
  final int availableStock;
  final String imageUrl;
  final List<String> categories;
  final double rating;
  final String size;
  final String color;
  final double? itemDiscount;
  final DateTime addedAt;
  final bool isLowStock;
  final bool isOutOfStock;

  CartItemUIModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    required this.availableStock,
    required this.imageUrl,
    this.categories = const [],
    this.rating = 0.0,
    this.size = '',
    this.color = '',
    this.itemDiscount,
    required this.addedAt,
    this.isLowStock = false,
    this.isOutOfStock = false,
  });

  /// Factory constructor from domain CartItem
  factory CartItemUIModel.fromEntity(CartItem item) {
    return CartItemUIModel(
      id: item.id,
      productId: item.productId,
      name: item.productName,
      description: '', // CartItem doesn't have description
      price: item.effectivePrice,
      originalPrice: item.price,
      quantity: item.quantity,
      availableStock: item.stockAvailable ?? 0,
      imageUrl: item.imageUrl ?? '',
      categories: const [], // CartItem mới không còn category
      rating: 0.0, // CartItem doesn't have rating
      size: item.selectedSize ?? '',
      color: item.selectedColorName ?? '',
      itemDiscount: item.hasDiscount
          ? item.discountPercentage.toDouble()
          : null,
      addedAt: item.dateAdded,
      isLowStock: item.isLowStock,
      isOutOfStock: item.isOutOfStock,
    );
  }

  /// Price Properties
  double get unitPrice => price;
  double get totalPrice => price * quantity;
  double get discountAmount => itemDiscount != null
      ? (originalPrice * quantity * itemDiscount! / 100)
      : 0;
  double get finalPrice => totalPrice;

  /// Formatted Price Strings
  String get formattedPrice => PriceFormatter.formatPrice(price);
  String get formattedTotalPrice => PriceFormatter.formatPrice(totalPrice);
  String get formattedDiscountAmount =>
      PriceFormatter.formatPrice(discountAmount);
  String get formattedFinalPrice => PriceFormatter.formatPrice(finalPrice);

  /// Display Properties
  String get displayName =>
      name.length > 30 ? '${name.substring(0, 27)}...' : name;

  String get customizationLabel {
    final customizations = <String>[];
    if (size.isNotEmpty) customizations.add(size);
    if (color.isNotEmpty) customizations.add(color);
    return customizations.join(', ');
  }

  bool get hasCustomization => size.isNotEmpty || color.isNotEmpty;

  /// Stock Status
  bool get canIncreaseQuantity => quantity < availableStock && !isOutOfStock;

  String get stockStatusLabel {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock (${availableStock} left)';
    return '${availableStock} in Stock';
  }

  String get stockStatusColor {
    if (isOutOfStock) return '#FF0000'; // Red
    if (isLowStock) return '#FFA500'; // Orange
    return '#00AA00'; // Green
  }

  /// Copy with method
  CartItemUIModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? quantity,
    int? availableStock,
    String? imageUrl,
    List<String>? categories,
    double? rating,
    String? size,
    String? color,
    double? itemDiscount,
    DateTime? addedAt,
    bool? isLowStock,
    bool? isOutOfStock,
  }) {
    return CartItemUIModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      size: size ?? this.size,
      color: color ?? this.color,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      addedAt: addedAt ?? this.addedAt,
      isLowStock: isLowStock ?? this.isLowStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
    );
  }

  @override
  String toString() {
    return 'CartItemUIModel(name: $displayName, qty: $quantity, price: $formattedTotalPrice)';
  }
}

/// Coupon UI Model
/// Coupon display representation with validation and formatting
class CouponUIModel {
  final String code;
  final String? description;
  final double discountValue; // The actual discount value
  final bool isPercentage; // true for %, false for fixed amount
  final double? minCartValue;
  final int? usageLimit;
  final int usageCount;
  final DateTime? expiryDate;
  final double? maxDiscount;

  CouponUIModel({
    required this.code,
    this.description,
    required this.discountValue,
    required this.isPercentage,
    this.minCartValue,
    this.usageLimit,
    required this.usageCount,
    this.expiryDate,
    this.maxDiscount,
  });

  /// Factory constructor from domain Coupon
  factory CouponUIModel.fromEntity(Coupon coupon) {
    return CouponUIModel(
      code: coupon.code,
      description: coupon.description,
      discountValue: coupon.discountValue,
      isPercentage: coupon.isPercentage,
      minCartValue: coupon.minCartValue,
      usageLimit: coupon.usageLimit,
      usageCount: coupon.usageCount,
      expiryDate: coupon.expiryDate,
      maxDiscount: coupon.maxDiscount,
    );
  }

  /// Coupon Status Properties
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isUsageExhausted => usageLimit != null && usageCount >= usageLimit!;

  bool get isValid => !isExpired && !isUsageExhausted;

  int get remainingUsages {
    if (usageLimit == null) return -1; // Unlimited
    return (usageLimit! - usageCount).clamp(0, usageLimit!);
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return -1; // No expiry
    final now = DateTime.now();
    if (isExpired) return 0;
    return expiryDate!.difference(now).inDays;
  }

  /// Formatted Display Strings
  String get formattedDiscountLabel {
    if (isPercentage) {
      return 'Save ${discountValue.toStringAsFixed(0)}%';
    }
    return 'Save ${PriceFormatter.formatPrice(discountValue)}';
  }

  String get formattedMinCartValue {
    if (minCartValue == null) return 'No minimum';
    return PriceFormatter.formatPrice(minCartValue!);
  }

  String get minPurchaseLabel => 'Minimum purchase: $formattedMinCartValue';

  /// Status Display
  String get statusLabel {
    if (isExpired) return 'EXPIRED';
    if (isUsageExhausted) return 'NO USES LEFT';
    return 'VALID';
  }

  String get expiryLabel {
    if (expiryDate == null) return 'No expiry';
    if (isExpired) return 'Expired';
    if (daysUntilExpiry == 0) return 'Expires today';
    if (daysUntilExpiry == 1) return 'Expires tomorrow';
    return 'Expires in $daysUntilExpiry days';
  }

  String get usageLabel {
    if (usageLimit == null) return 'Unlimited uses';
    return '$usageCount / $usageLimit uses';
  }

  /// Copy with method
  CouponUIModel copyWith({
    String? code,
    String? description,
    double? discountValue,
    bool? isPercentage,
    double? minCartValue,
    int? usageLimit,
    int? usageCount,
    DateTime? expiryDate,
    double? maxDiscount,
  }) {
    return CouponUIModel(
      code: code ?? this.code,
      description: description ?? this.description,
      discountValue: discountValue ?? this.discountValue,
      isPercentage: isPercentage ?? this.isPercentage,
      minCartValue: minCartValue ?? this.minCartValue,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      expiryDate: expiryDate ?? this.expiryDate,
      maxDiscount: maxDiscount ?? this.maxDiscount,
    );
  }

  @override
  String toString() {
    return 'CouponUIModel(code: $code, discount: $formattedDiscountLabel, valid: $isValid)';
  }
}

/// Wishlist Item UI Model
/// Wishlist item display representation
class WishlistItemUIModel {
  final String id;
  final String productId;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int availableStock;
  final String imageUrl;
  final List<String> categories;
  final double rating;
  final DateTime addedAt;
  final bool isOnSale;
  final bool isLowStock;
  final bool isOutOfStock;

  WishlistItemUIModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.availableStock,
    required this.imageUrl,
    this.categories = const [],
    this.rating = 0.0,
    required this.addedAt,
    this.isOnSale = false,
    this.isLowStock = false,
    this.isOutOfStock = false,
  });

  /// Factory constructor from domain WishlistItem
  factory WishlistItemUIModel.fromEntity(WishlistItem item) {
    return WishlistItemUIModel(
      id: item.id,
      productId: item.productId,
      name: item.productName,
      description: item.notes ?? '',
      price: item.salePrice ?? item.price,
      originalPrice: item.price,
      availableStock: item.stockAvailable ?? 0,
      imageUrl: item.imageUrl ?? '',
      categories: item.category != null ? [item.category!] : [],
      rating: item.rating ?? 0.0,
      addedAt: item.dateAdded,
      isOnSale: item.hasDiscount,
      isLowStock: (item.stockAvailable ?? 0) < 5,
      isOutOfStock: (item.stockAvailable ?? 0) <= 0,
    );
  }

  /// Price Properties
  double get discountAmount => originalPrice - price;

  double get discountPercent =>
      originalPrice > 0 ? ((discountAmount / originalPrice) * 100) : 0;

  /// Formatted Prices
  String get formattedPrice => PriceFormatter.formatPrice(price);
  String get formattedOriginalPrice =>
      PriceFormatter.formatPrice(originalPrice);
  String get formattedDiscountAmount =>
      PriceFormatter.formatPrice(discountAmount);
  String get formattedDiscountPercent =>
      '${discountPercent.toStringAsFixed(0)}%';

  /// Display Properties
  String get displayName =>
      name.length > 30 ? '${name.substring(0, 27)}...' : name;

  /// Stock Status
  String get stockStatusLabel {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock (${availableStock} left)';
    return 'In Stock';
  }

  bool get isAvailable => !isOutOfStock;

  /// Copy with method
  WishlistItemUIModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? availableStock,
    String? imageUrl,
    List<String>? categories,
    double? rating,
    DateTime? addedAt,
    bool? isOnSale,
    bool? isLowStock,
    bool? isOutOfStock,
  }) {
    return WishlistItemUIModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      availableStock: availableStock ?? this.availableStock,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      addedAt: addedAt ?? this.addedAt,
      isOnSale: isOnSale ?? this.isOnSale,
      isLowStock: isLowStock ?? this.isLowStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
    );
  }

  @override
  String toString() {
    return 'WishlistItemUIModel(name: $displayName, price: $formattedPrice, available: $isAvailable)';
  }
}

/// Price Breakdown UI Model
/// Detailed price calculation breakdown for display
class PriceBreakdownUIModel {
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double shippingAmount;
  final double total;

  PriceBreakdownUIModel({
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.total,
  });

  /// Factory from CartUIModel
  factory PriceBreakdownUIModel.fromCart(CartUIModel cart) {
    return PriceBreakdownUIModel(
      subtotal: cart.subtotal,
      discountAmount: cart.discountAmount,
      taxAmount: cart.taxAmount,
      shippingAmount: cart.shippingAmount,
      total: cart.total,
    );
  }

  /// Formatted Display Strings
  String get formattedSubtotal => PriceFormatter.formatPrice(subtotal);
  String get formattedDiscountAmount =>
      PriceFormatter.formatPrice(discountAmount);
  String get formattedTaxAmount => PriceFormatter.formatPrice(taxAmount);
  String get formattedShippingAmount =>
      PriceFormatter.formatPrice(shippingAmount);
  String get formattedTotal => PriceFormatter.formatPrice(total);

  /// Summary display
  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('Subtotal: $formattedSubtotal');
    buffer.writeln('Discount: -$formattedDiscountAmount');
    buffer.writeln('Tax: $formattedTaxAmount');
    buffer.writeln('Shipping: $formattedShippingAmount');
    buffer.write('Total: $formattedTotal');
    return buffer.toString();
  }

  /// Copy with method
  PriceBreakdownUIModel copyWith({
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? shippingAmount,
    double? total,
  }) {
    return PriceBreakdownUIModel(
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      total: total ?? this.total,
    );
  }

  @override
  String toString() {
    return 'PriceBreakdownUIModel(total: $formattedTotal)';
  }
}
