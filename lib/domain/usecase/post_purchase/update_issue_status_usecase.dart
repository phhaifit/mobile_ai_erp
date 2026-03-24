import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class UpdateIssueStatusParams {
  UpdateIssueStatusParams({required this.id, required this.status});

  final String id;
  final IssueStatus status;
}

class UpdateIssueStatusUseCase extends UseCase<void, UpdateIssueStatusParams> {
  final PostPurchaseRepository _repository;

  UpdateIssueStatusUseCase(this._repository);

  @override
  Future<void> call({required params}) {
    return _repository.updateIssueStatus(params.id, params.status);
  }
}
