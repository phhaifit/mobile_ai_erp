import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class DeleteCustomerUseCase extends UseCase<void, String> {
  final CustomerRepository _repository;

  DeleteCustomerUseCase(this._repository);

  @override
  Future<void> call({required String params}) {
    return _repository.deleteCustomer(params);
  }
}
