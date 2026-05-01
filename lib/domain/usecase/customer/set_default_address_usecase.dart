import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class SetDefaultAddressParams {
  final String customerId;
  final String addressId;

  const SetDefaultAddressParams({
    required this.customerId,
    required this.addressId,
  });
}

class SetDefaultAddressUseCase
    extends UseCase<void, SetDefaultAddressParams> {
  final CustomerRepository _repository;

  SetDefaultAddressUseCase(this._repository);

  @override
  Future<void> call({required SetDefaultAddressParams params}) {
    return _repository.setDefaultAddress(params.customerId, params.addressId);
  }
}
