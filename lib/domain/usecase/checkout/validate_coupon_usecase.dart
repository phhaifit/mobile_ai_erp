import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';

/// Parameters for validating a coupon
class ValidateCouponParams {
  const ValidateCouponParams({
    required this.code,
    this.orderTotal,
  });

  final String code;
  final double? orderTotal;
}

/// Use case for validating and retrieving a coupon
class ValidateCouponUseCase extends UseCase<Coupon?, ValidateCouponParams> {
  ValidateCouponUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Coupon?> call({required ValidateCouponParams params}) {
    return _repository.validateCoupon(
      params.code,
      orderTotal: params.orderTotal,
    );
  }
}
