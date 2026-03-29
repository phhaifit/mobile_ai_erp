import 'package:mobile_ai_erp/data/local/datasources/post_purchase/post_purchase_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/order_complaint_candidate.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class PostPurchaseRepositoryImpl extends PostPurchaseRepository {
  PostPurchaseRepositoryImpl(this._dataSource);

  final PostPurchaseDataSource _dataSource;

  @override
  Future<List<OrderComplaintCandidate>> getOrderPool() => _dataSource.getOrderPool();

  @override
  Future<List<IssueTicket>> getIssues() => _dataSource.getIssues();

  @override
  Future<IssueTicket?> getIssueById(String id) => _dataSource.getIssueById(id);

  @override
  Future<String> createIssue({
    required String orderId,
    required String customerName,
    required String subject,
    required String description,
    IssuePriority priority = IssuePriority.medium,
    String channel = 'Manual',
  }) =>
      _dataSource.createIssue(
        orderId: orderId,
        customerName: customerName,
        subject: subject,
        description: description,
        priority: priority,
        channel: channel,
      );

  @override
  Future<void> executeIssueAction(String id, IssueAction action) =>
      _dataSource.executeIssueAction(id, action);

  @override
  Future<void> updateIssueNotes(String id, String notes) =>
      _dataSource.updateIssueNotes(id, notes);

  @override
  Future<List<ExchangeRequest>> getExchanges() => _dataSource.getExchanges();

  @override
  Future<ExchangeRequest?> getExchangeById(String id) =>
      _dataSource.getExchangeById(id);

  @override
  Future<String> createExchangeFromIssue({
    required String issueId,
    required String reason,
  }) =>
      _dataSource.createExchangeFromIssue(
        issueId: issueId,
        reason: reason,
      );

  @override
  Future<void> executeExchangeAction(String id, ExchangeAction action) =>
      _dataSource.executeExchangeAction(id, action);

  @override
  Future<void> updateExchangeNotes(String id, String notes) =>
      _dataSource.updateExchangeNotes(id, notes);

  @override
  Future<List<RefundRequest>> getRefunds() => _dataSource.getRefunds();

  @override
  Future<RefundRequest?> getRefundById(String id) => _dataSource.getRefundById(id);

  @override
  Future<String> createRefundFromIssue({
    required String issueId,
    required String reason,
    double? refundAmount,
  }) =>
      _dataSource.createRefundFromIssue(
        issueId: issueId,
        reason: reason,
        refundAmount: refundAmount,
      );

  @override
  Future<void> executeRefundAction(String id, RefundAction action) =>
      _dataSource.executeRefundAction(id, action);

  @override
  Future<void> updateRefundNotes(String id, String notes) =>
      _dataSource.updateRefundNotes(id, notes);
}
