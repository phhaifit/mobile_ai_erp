import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class SaveCustomerUseCase extends UseCase<Customer, Customer> {
  final CustomerRepository _repository;

  SaveCustomerUseCase(this._repository);

  @override
  Future<Customer> call({required Customer params}) {
    return _repository.saveCustomer(params);
  }
}
