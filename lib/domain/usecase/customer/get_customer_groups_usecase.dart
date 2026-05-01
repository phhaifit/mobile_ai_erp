import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class GetCustomerGroupsParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  const GetCustomerGroupsParams({
    this.page = 1,
    this.pageSize = 5,
    this.search,
    this.sortBy,
    this.sortOrder,
  });
}

class GetCustomerGroupsUseCase
    extends UseCase<CustomerGroupListResult, GetCustomerGroupsParams> {
  final CustomerRepository _repository;

  GetCustomerGroupsUseCase(this._repository);

  @override
  Future<CustomerGroupListResult> call({
    required GetCustomerGroupsParams params,
  }) {
    return _repository.getCustomerGroups(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );
  }
}
