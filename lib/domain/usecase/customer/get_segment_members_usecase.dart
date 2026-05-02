import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class GetSegmentMembersParams {
  final String groupId;
  final int page;
  final int pageSize;

  const GetSegmentMembersParams({
    required this.groupId,
    this.page = 1,
    this.pageSize = 20,
  });
}

class GetSegmentMembersUseCase
    extends UseCase<CustomerMemberListResult, GetSegmentMembersParams> {
  final CustomerRepository _repository;

  GetSegmentMembersUseCase(this._repository);

  @override
  Future<CustomerMemberListResult> call(
      {required GetSegmentMembersParams params}) {
    return _repository.getSegmentMembers(
      params.groupId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
