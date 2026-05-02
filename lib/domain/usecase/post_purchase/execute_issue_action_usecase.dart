import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class ExecuteIssueActionParams {
  ExecuteIssueActionParams({required this.id, required this.action});

  final String id;
  final IssueAction action;
}

class ExecuteIssueActionUseCase
    extends UseCase<void, ExecuteIssueActionParams> {
  ExecuteIssueActionUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<void> call({required params}) {
    return _repository.executeIssueAction(params.id, params.action);
  }
}
