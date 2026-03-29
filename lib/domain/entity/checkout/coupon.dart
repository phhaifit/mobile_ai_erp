/// Enum representing coupon discount type
enum CouponDiscountType {
  percentage('Percentage Discount'),
  fixed('Fixed Amount Discount'),
  freeShipping('Free Shipping');

  const CouponDiscountType(this.displayName);

  final String displayName;
}

/// Represents a coupon/voucher that can be applied at checkout
class Coupon {
  const Coupon({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.isValid,
    this.description,
    this.minOrderAmount = 0.0,
    this.maxDiscountAmount,
    this.usageLimit,
    this.usageCount = 0,
    this.validFrom,
    this.validUntil,
    this.applicableProductIds,
    this.applicableCategoryIds,
    this.isFirstOrderOnly = false,
    this.freeShipping = false,
  });

  /// Unique coupon code
  final String code;

  /// Type of discount
  final CouponDiscountType discountType;

  /// Discount value (percentage or fixed amount based on type)
  final double discountValue;

  /// Whether the coupon is currently valid
  final bool isValid;

  /// Human-readable description
  final String? description;

  /// Minimum order amount required
  final double minOrderAmount;

  /// Maximum discount amount (for percentage discounts)
  final double? maxDiscountAmount;

  /// Total usage limit
  final int? usageLimit;

  /// Current usage count
  final int usageCount;

  /// Valid from date
  final DateTime? validFrom;

  /// Valid until date
  final DateTime? validUntil;

  /// Product IDs this coupon applies to (null = all products)
  final List<String>? applicableProductIds;

  /// Category IDs this coupon applies to (null = all categories)
  final List<String>? applicableCategoryIds;

  /// Whether this coupon is for first orders only
  final bool isFirstOrderOnly;

  /// Whether this coupon provides free shipping
  final bool freeShipping;

  /// Check if coupon is expired
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Check if coupon has not started yet
  bool get isNotStarted {
    if (validFrom == null) return false;
    return DateTime.now().isBefore(validFrom!);
  }

  /// Check if coupon has reached usage limit
  bool get hasReachedUsageLimit {
    if (usageLimit == null) return false;
    return usageCount >= usageLimit!;
  }

  /// Calculate discount amount for a given order total
  double calculateDiscount(double orderTotal, {double? shippingCost}) {
    if (!isValid || isExpired || isNotStarted || hasReachedUsageLimit) {
      return 0.0;
    }

    if (orderTotal < minOrderAmount) {
      return 0.0;
    }

    switch (discountType) {
      case CouponDiscountType.percentage:
        final discount = orderTotal * (discountValue / 100);
        return maxDiscountAmount != null
            ? discount.clamp(0, maxDiscountAmount!)
            : discount;
      case CouponDiscountType.fixed:
        return discountValue.clamp(0, orderTotal);
      case CouponDiscountType.freeShipping:
        return shippingCost ?? 0.0;
    }
  }

  /// Get discount description
  String get discountDescription {
    switch (discountType) {
      case CouponDiscountType.percentage:
        return '${discountValue.toInt()}% off';
      case CouponDiscountType.fixed:
        return '\$${discountValue.toStringAsFixed(2)} off';
      case CouponDiscountType.freeShipping:
        return 'Free Shipping';
    }
  }

  /// Validate coupon and return error message if invalid
  String? validate(double orderTotal, {bool isFirstOrder = false}) {
    if (!isValid) return 'This coupon is no longer valid';
    if (isExpired) return 'This coupon has expired';
    if (isNotStarted) return 'This coupon is not yet active';
    if (hasReachedUsageLimit) return 'This coupon has reached its usage limit';
    if (orderTotal < minOrderAmount) {
      return 'Minimum order amount is \$${minOrderAmount.toStringAsFixed(2)}';
    }
    if (isFirstOrderOnly && !isFirstOrder) {
      return 'This coupon is only valid for first orders';
    }
    return null;
  }

  Coupon copyWith({
    String? code,
    CouponDiscountType? discountType,
    double? discountValue,
    bool? isValid,
    String? description,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usageCount,
    DateTime? validFrom,
    DateTime? validUntil,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
    bool? isFirstOrderOnly,
    bool? freeShipping,
  }) {
    return Coupon(
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      isValid: isValid ?? this.isValid,
      description: description ?? this.description,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds:
          applicableCategoryIds ?? this.applicableCategoryIds,
      isFirstOrderOnly: isFirstOrderOnly ?? this.isFirstOrderOnly,
      freeShipping: freeShipping ?? this.freeShipping,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coupon && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
