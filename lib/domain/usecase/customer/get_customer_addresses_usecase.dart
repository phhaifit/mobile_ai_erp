import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class GetCustomerAddressesUseCase extends UseCase<List<Address>, String> {
  final CustomerRepository _repository;

  GetCustomerAddressesUseCase(this._repository);

  @override
  Future<List<Address>> call({required String params}) {
    return _repository.getAddresses(params);
  }
}
