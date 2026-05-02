import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';

class AddSegmentMembersParams {
  final String groupId;
  final List<String> customerIds;

  const AddSegmentMembersParams({
    required this.groupId,
    required this.customerIds,
  });
}

class AddSegmentMembersUseCase
    extends UseCase<void, AddSegmentMembersParams> {
  final CustomerRepository _repository;

  AddSegmentMembersUseCase(this._repository);

  @override
  Future<void> call({required AddSegmentMembersParams params}) {
    return _repository.addSegmentMembers(params.groupId, params.customerIds);
  }
}
