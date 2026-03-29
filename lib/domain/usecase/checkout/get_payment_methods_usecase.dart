import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';

/// Parameters for getting payment methods
class GetPaymentMethodsParams {
  const GetPaymentMethodsParams({
    this.orderTotal,
    this.countryCode,
  });

  final double? orderTotal;
  final String? countryCode;
}

/// Use case for retrieving available payment methods
class GetPaymentMethodsUseCase
    extends UseCase<List<PaymentMethod>, GetPaymentMethodsParams> {
  GetPaymentMethodsUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<List<PaymentMethod>> call({
    required GetPaymentMethodsParams params,
  }) {
    return _repository.getPaymentMethods(
      orderTotal: params.orderTotal,
      countryCode: params.countryCode,
    );
  }
}
