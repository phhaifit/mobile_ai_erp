import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class LinkIssueToReturnParams {
  LinkIssueToReturnParams({required this.issueId, required this.returnId});

  final String issueId;
  final String returnId;
}

class LinkIssueToReturnUseCase extends UseCase<void, LinkIssueToReturnParams> {
  final PostPurchaseRepository _repository;

  LinkIssueToReturnUseCase(this._repository);

  @override
  Future<void> call({required params}) {
    return _repository.linkIssueToReturn(
      issueId: params.issueId,
      returnId: params.returnId,
    );
  }
}
