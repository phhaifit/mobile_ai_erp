import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class CreateExchangeFromIssueParams {
  CreateExchangeFromIssueParams({
    required this.issueId,
    required this.reason,
  });

  final String issueId;
  final String reason;
}

class CreateExchangeFromIssueUseCase
    extends UseCase<String, CreateExchangeFromIssueParams> {
  CreateExchangeFromIssueUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<String> call({required params}) {
    return _repository.createExchangeFromIssue(
      issueId: params.issueId,
      reason: params.reason,
    );
  }
}
