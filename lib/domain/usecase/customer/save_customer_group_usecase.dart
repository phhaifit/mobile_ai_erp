import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class SaveCustomerGroupUseCase extends UseCase<CustomerGroup, CustomerGroup> {
  final CustomerRepository _repository;

  SaveCustomerGroupUseCase(this._repository);

  @override
  Future<CustomerGroup> call({required CustomerGroup params}) {
    return _repository.saveCustomerGroup(params);
  }
}
