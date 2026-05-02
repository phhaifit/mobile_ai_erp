import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class SaveCustomerAddressUseCase extends UseCase<Address, Address> {
  final CustomerRepository _repository;

  SaveCustomerAddressUseCase(this._repository);

  @override
  Future<Address> call({required Address params}) {
    return _repository.saveAddress(params);
  }
}
