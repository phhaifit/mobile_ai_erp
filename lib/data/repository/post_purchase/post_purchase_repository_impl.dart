import 'package:mobile_ai_erp/data/local/datasources/post_purchase/post_purchase_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';

class PostPurchaseRepositoryImpl extends PostPurchaseRepository {
  PostPurchaseRepositoryImpl(this._dataSource);

  final PostPurchaseDataSource _dataSource;

  @override
  Future<List<IssueTicket>> getIssues() => _dataSource.getIssues();

  @override
  Future<IssueTicket?> getIssueById(String id) =>
      _dataSource.getIssueById(id);

  @override
  Future<void> updateIssueStatus(String id, IssueStatus status) =>
      _dataSource.updateIssueStatus(id, status);

  @override
  Future<void> updateIssueNotes(String id, String notes) =>
      _dataSource.updateIssueNotes(id, notes);

  @override
  Future<void> linkIssueToReturn({required String issueId, required String returnId}) =>
      _dataSource.linkIssueToReturn(issueId: issueId, returnId: returnId);

  @override
  Future<List<ReturnExchangeRequest>> getReturns() => _dataSource.getReturns();

  @override
  Future<ReturnExchangeRequest?> getReturnById(String id) =>
      _dataSource.getReturnById(id);

  @override
  Future<void> updateReturnStatus(String id, ReturnStatus status) =>
      _dataSource.updateReturnStatus(id, status);

  @override
  Future<void> updateReturnNotes(String id, String notes) =>
      _dataSource.updateReturnNotes(id, notes);

  @override
  Future<void> convertExchangeToRefund(String id) =>
      _dataSource.convertExchangeToRefund(id);
}

