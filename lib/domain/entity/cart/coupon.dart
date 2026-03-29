import 'package:mobile_ai_erp/domain/entity/cart/cart_exception.dart';

/// Coupon/Promotion code entity for shopping cart
class Coupon {
  final String code;

  /// Discount value (either percentage or fixed amount)
  final double discountValue;

  /// True if discount is percentage (%), false if fixed amount ($)
  final bool isPercentage;

  /// Coupon expiry date (null means never expires)
  final DateTime? expiryDate;

  /// Minimum cart subtotal required to apply this coupon
  final double? minCartValue;

  /// Maximum discount cap (e.g., max $100 discount even at high percentages)
  final double? maxDiscount;

  /// Description of the coupon (e.g., "20% off summer collection")
  final String? description;

  /// Whether coupon is active
  final bool isActive;

  /// Number of times this coupon can be used (null means unlimited)
  final int? usageLimit;

  /// Number of times coupon has already been used
  final int usageCount;

  Coupon({
    required this.code,
    required this.discountValue,
    required this.isPercentage,
    this.expiryDate,
    this.minCartValue,
    this.maxDiscount,
    this.description,
    this.isActive = true,
    this.usageLimit,
    this.usageCount = 0,
  });

  /// Check if coupon is valid (not expired, not exceeded usage limit, etc)
  bool get isValid {
    if (!isActive) return false;

    // Check if expired
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) {
      return false;
    }

    // Check usage limit
    if (usageLimit != null && usageCount >= usageLimit!) {
      return false;
    }

    return true;
  }

  /// Check if coupon is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Check if usage limit is reached
  bool get isUsageLimitReached {
    if (usageLimit == null) return false;
    return usageCount >= usageLimit!;
  }

  /// Calculate discount amount based on cart subtotal
  /// Throws [InvalidCouponException] if coupon is not valid
  /// Throws [CouponMinimumValueException] if cart value is below minimum
  double calculateDiscount(double cartSubtotal) {
    if (!isValid) {
      throw InvalidCouponException(couponCode: code);
    }

    // Check minimum cart value requirement
    if (minCartValue != null && cartSubtotal < minCartValue!) {
      throw CouponMinimumValueException(
        minValue: minCartValue!,
        currentValue: cartSubtotal,
        couponCode: code,
      );
    }

    double discount;

    if (isPercentage) {
      // Percentage-based discount
      discount = (cartSubtotal * discountValue) / 100;
    } else {
      // Fixed amount discount
      discount = discountValue;
    }

    // Apply max discount cap if specified
    if (maxDiscount != null && discount > maxDiscount!) {
      discount = maxDiscount!;
    }

    return discount;
  }

  /// Get discount display text (e.g., "20% off" or "$50 off")
  String get displayText {
    if (isPercentage) {
      return '${discountValue.toStringAsFixed(0)}% off';
    } else {
      return '\$${discountValue.toStringAsFixed(2)} off';
    }
  }

  /// Create a copy of this coupon with modified fields
  Coupon copyWith({
    String? code,
    double? discountValue,
    bool? isPercentage,
    DateTime? expiryDate,
    double? minCartValue,
    double? maxDiscount,
    String? description,
    bool? isActive,
    int? usageLimit,
    int? usageCount,
  }) {
    return Coupon(
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      isPercentage: isPercentage ?? this.isPercentage,
      expiryDate: expiryDate ?? this.expiryDate,
      minCartValue: minCartValue ?? this.minCartValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  String toString() =>
      'Coupon(code: $code, discount: $displayText, valid: $isValid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coupon && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}
