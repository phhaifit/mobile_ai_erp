import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/order_complaint_candidate.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';

abstract class PostPurchaseRepository {
  Future<List<OrderComplaintCandidate>> getOrderPool();

  Future<List<IssueTicket>> getIssues();
  Future<IssueTicket?> getIssueById(String id);
  Future<String> createIssue({
    required String orderId,
    required String customerName,
    required String subject,
    required String description,
    IssuePriority priority,
    String channel,
  });
  Future<void> executeIssueAction(String id, IssueAction action);
  Future<void> updateIssueNotes(String id, String notes);

  Future<List<ExchangeRequest>> getExchanges();
  Future<ExchangeRequest?> getExchangeById(String id);
  Future<String> createExchangeFromIssue({
    required String issueId,
    required String reason,
  });
  Future<void> executeExchangeAction(String id, ExchangeAction action);
  Future<void> updateExchangeNotes(String id, String notes);

  Future<List<RefundRequest>> getRefunds();
  Future<RefundRequest?> getRefundById(String id);
  Future<String> createRefundFromIssue({
    required String issueId,
    required String reason,
    double? refundAmount,
  });
  Future<void> executeRefundAction(String id, RefundAction action);
  Future<void> updateRefundNotes(String id, String notes);
}
