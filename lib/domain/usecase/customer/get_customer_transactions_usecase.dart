import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_order.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class GetCustomerTransactionsUseCase
    extends UseCase<List<CustomerOrder>, String> {
  final CustomerRepository _repository;

  GetCustomerTransactionsUseCase(this._repository);

  @override
  Future<List<CustomerOrder>> call({required String params}) {
    return _repository.getCustomerTransactions(params);
  }
}
