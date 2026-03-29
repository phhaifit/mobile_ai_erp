import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class CreateIssueParams {
  CreateIssueParams({
    required this.orderId,
    required this.customerName,
    required this.subject,
    required this.description,
    this.priority = IssuePriority.medium,
    this.channel = 'Manual',
  });

  final String orderId;
  final String customerName;
  final String subject;
  final String description;
  final IssuePriority priority;
  final String channel;
}

class CreateIssueUseCase extends UseCase<String, CreateIssueParams> {
  CreateIssueUseCase(this._repository);

  final PostPurchaseRepository _repository;

  @override
  Future<String> call({required params}) {
    return _repository.createIssue(
      orderId: params.orderId,
      customerName: params.customerName,
      subject: params.subject,
      description: params.description,
      priority: params.priority,
      channel: params.channel,
    );
  }
}
