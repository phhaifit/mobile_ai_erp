import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class GetCustomersParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? status;
  final String? groupId;
  final String? sortBy;
  final String? sortOrder;

  const GetCustomersParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.status,
    this.groupId,
    this.sortBy,
    this.sortOrder,
  });
}

class GetCustomersUseCase extends UseCase<CustomerListResult, GetCustomersParams> {
  final CustomerRepository _repository;

  GetCustomersUseCase(this._repository);

  @override
  Future<CustomerListResult> call({required GetCustomersParams params}) {
    return _repository.getCustomers(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      status: params.status,
      groupId: params.groupId,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}
