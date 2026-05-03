import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class GetCustomerDetailUseCase extends UseCase<Customer?, String> {
  final CustomerRepository _repository;

  GetCustomerDetailUseCase(this._repository);

  @override
  Future<Customer?> call({required String params}) {
    return _repository.getCustomerById(params);
  }
}
