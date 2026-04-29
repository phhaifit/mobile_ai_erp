import 'package:mobile_ai_erp/data/network/apis/coupon/coupon_api.dart';
import 'package:mobile_ai_erp/data/repository/coupon/coupon_repository.dart';
import 'package:mobile_ai_erp/domain/entity/coupon/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/coupon/validated_coupon.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponApi _couponApi;

  CouponRepositoryImpl({required CouponApi couponApi}) : _couponApi = couponApi;

  @override
  Future<List<Coupon>> getCoupons() async {
    final res = await _couponApi.getCoupons();
    return res.map((e) => _mapCoupon(e)).toList();
  }

  @override
  Future<ValidatedCoupon> validateCoupon({
    required String couponCode,
    required num subtotal,
  }) async {
    final res = await _couponApi.validateCoupon(
      couponCode: couponCode,
      subtotal: subtotal,
    );

    final promotionJson = res['promotion'] is Map
        ? Map<String, dynamic>.from(res['promotion'] as Map)
        : null;

    return ValidatedCoupon(
      code: promotionJson?['code']?.toString() ?? couponCode,
      isValid: res['isValid'] as bool? ?? false,
      discountAmount: (res['discountAmount'] ?? 0).toString(),
      reason: res['reason']?.toString(),
      promotion: promotionJson == null ? null : _mapCoupon(promotionJson),
    );
  }

  Coupon _mapCoupon(Map<String, dynamic> json) {
    return Coupon(
      id: (json['id'] ?? '').toString(),
      tenantId: (json['tenant_id'] ?? json['tenantId'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      discountType: (json['discount_type'] ?? json['discountType'] ?? '')
          .toString(),
      discountValue: (json['discount_value'] ?? json['discountValue'] ?? '0')
          .toString(),
      minOrderAmount:
          (json['min_order_amount'] ?? json['minOrderAmount'] ?? '0')
              .toString(),
      maxUses: (json['max_uses'] ?? json['maxUses'] as num?)?.toInt(),
      usedCount:
          (json['used_count'] ?? json['usedCount'] as num?)?.toInt() ?? 0,
      validFrom: DateTime.parse(
        (json['valid_from'] ?? json['validFrom']).toString(),
      ),
      validTo: DateTime.parse((json['valid_to'] ?? json['validTo']).toString()),
      isActive:
          json['is_active'] as bool? ?? json['isActive'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
    );
  }
}
