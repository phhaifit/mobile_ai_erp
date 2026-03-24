import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';

abstract class PostPurchaseRepository {
  Future<List<IssueTicket>> getIssues();
  Future<IssueTicket?> getIssueById(String id);
  Future<void> updateIssueStatus(String id, IssueStatus status);
  Future<void> updateIssueNotes(String id, String notes);
  Future<void> linkIssueToReturn({required String issueId, required String returnId});

  Future<List<ReturnExchangeRequest>> getReturns();
  Future<ReturnExchangeRequest?> getReturnById(String id);
  Future<void> updateReturnStatus(String id, ReturnStatus status);
  Future<void> updateReturnNotes(String id, String notes);
  Future<void> convertExchangeToRefund(String id);
}

