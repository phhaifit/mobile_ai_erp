import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class RemoveSegmentMembersParams {
  final String groupId;
  final List<String> customerIds;

  const RemoveSegmentMembersParams({
    required this.groupId,
    required this.customerIds,
  });
}

class RemoveSegmentMembersUseCase
    extends UseCase<void, RemoveSegmentMembersParams> {
  final CustomerRepository _repository;

  RemoveSegmentMembersUseCase(this._repository);

  @override
  Future<void> call({required RemoveSegmentMembersParams params}) {
    return _repository.removeSegmentMembers(
        params.groupId, params.customerIds);
  }
}
