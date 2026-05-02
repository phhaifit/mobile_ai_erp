import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetIssueDetailUseCase extends UseCase<IssueTicket?, String> {
  final PostPurchaseRepository _repository;

  GetIssueDetailUseCase(this._repository);

  @override
  Future<IssueTicket?> call({required params}) {
    return _repository.getIssueById(params);
  }
}
