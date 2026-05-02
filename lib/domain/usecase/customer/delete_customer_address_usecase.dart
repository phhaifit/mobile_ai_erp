import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class DeleteCustomerAddressParams {
  final String customerId;
  final String addressId;

  const DeleteCustomerAddressParams({
    required this.customerId,
    required this.addressId,
  });
}

class DeleteCustomerAddressUseCase
    extends UseCase<void, DeleteCustomerAddressParams> {
  final CustomerRepository _repository;

  DeleteCustomerAddressUseCase(this._repository);

  @override
  Future<void> call({required DeleteCustomerAddressParams params}) {
    return _repository.deleteAddress(params.customerId, params.addressId);
  }
}
