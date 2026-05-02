import 'package:mobile_ai_erp/domain/entity/coupon/coupon.dart';

// used in cart
class ValidatedCoupon {
  final String code;
  final bool isValid;
  final String discountAmount;
  final String? reason;
  final Coupon? promotion;

  const ValidatedCoupon({
    required this.code,
    required this.isValid,
    required this.discountAmount,
    this.reason,
    this.promotion,
  });
}
