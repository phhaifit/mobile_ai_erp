import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class GetIssueListUseCase extends UseCase<List<IssueTicket>, void> {
  final PostPurchaseRepository _repository;

  GetIssueListUseCase(this._repository);

  @override
  Future<List<IssueTicket>> call({required params}) {
    return _repository.getIssues();
  }
}
