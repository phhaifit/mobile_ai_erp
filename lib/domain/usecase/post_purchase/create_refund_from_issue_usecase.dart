import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class CreateRefundFromIssueParams {
  CreateRefundFromIssueParams({
    required this.issueId,
    required this.reason,
    this.refundAmount,
  });

  final String issueId;
  final String reason;
  final double? refundAmount;
}

class CreateRefundFromIssueUseCase
    extends UseCase<String, CreateRefundFromIssueParams> {
  CreateRefundFromIssueUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<String> call({required params}) {
    return _repository.createRefundFromIssue(
      issueId: params.issueId,
      reason: params.reason,
      refundAmount: params.refundAmount,
    );
  }
}
