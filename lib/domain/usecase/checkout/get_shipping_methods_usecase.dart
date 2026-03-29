import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';

/// Parameters for getting shipping methods
class GetShippingMethodsParams {
  const GetShippingMethodsParams({
    required this.countryCode,
    this.orderTotal,
    this.totalWeight,
  });

  final String countryCode;
  final double? orderTotal;
  final double? totalWeight;
}

/// Use case for retrieving available shipping methods
class GetShippingMethodsUseCase
    extends UseCase<List<ShippingMethod>, GetShippingMethodsParams> {
  GetShippingMethodsUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<List<ShippingMethod>> call({
    required GetShippingMethodsParams params,
  }) {
    return _repository.getShippingMethods(
      countryCode: params.countryCode,
      orderTotal: params.orderTotal,
      totalWeight: params.totalWeight,
    );
  }
}
