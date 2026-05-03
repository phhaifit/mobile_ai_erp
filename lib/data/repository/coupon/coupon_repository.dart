import 'package:mobile_ai_erp/domain/entity/coupon/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/coupon/validated_coupon.dart';

abstract class CouponRepository {
  Future<List<Coupon>> getCoupons();

  Future<ValidatedCoupon> validateCoupon({
    required String couponCode,
    required num subtotal,
  });
}
