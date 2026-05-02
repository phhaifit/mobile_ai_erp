import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';

class CartCalculation {
  final List<CartItem> items;
  final CartCalculationSummary summary;
  final AppliedCoupon? coupon;

  const CartCalculation({
    required this.items,
    required this.summary,
    this.coupon,
  });

  CartCalculation copyWith({
    List<CartItem>? items,
    CartCalculationSummary? summary,
    AppliedCoupon? coupon,
  }) {
    return CartCalculation(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      coupon: coupon ?? this.coupon,
    );
  }

  @override
  String toString() {
    return 'CartCalculation(items: ${items.length}, total: ${summary.total})';
  }
}

class CartCalculationSummary {
  final String subtotal;
  final String discount;
  final String total;
  final int selectedItemsCount;
  final int selectedQuantity;

  const CartCalculationSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.selectedItemsCount,
    required this.selectedQuantity,
  });

  CartCalculationSummary copyWith({
    String? subtotal,
    String? discount,
    String? total,
    int? selectedItemsCount,
    int? selectedQuantity,
  }) {
    return CartCalculationSummary(
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      selectedItemsCount: selectedItemsCount ?? this.selectedItemsCount,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
    );
  }
}

class AppliedCoupon {
  final String code;
  final String? name;
  final bool isApplied;
  final bool isValid;
  final String? discountAmount;
  final String? reason;

  const AppliedCoupon({
    required this.code,
    this.name,
    required this.isApplied,
    required this.isValid,
    this.discountAmount,
    this.reason,
  });

  AppliedCoupon copyWith({
    String? code,
    String? name,
    bool? isApplied,
    bool? isValid,
    String? discountAmount,
    String? reason,
  }) {
    return AppliedCoupon(
      code: code ?? this.code,
      name: name ?? this.name,
      isApplied: isApplied ?? this.isApplied,
      isValid: isValid ?? this.isValid,
      discountAmount: discountAmount ?? this.discountAmount,
      reason: reason ?? this.reason,
    );
  }
}
