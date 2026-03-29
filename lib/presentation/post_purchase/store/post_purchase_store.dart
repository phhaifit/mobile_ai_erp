import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/order_complaint_candidate.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_exchange_from_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_refund_from_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_exchange_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_issue_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_refund_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_exchange_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_exchange_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_order_pool_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_refund_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_refund_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_exchange_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_refund_notes_usecase.dart';

class PostPurchaseStore {
  PostPurchaseStore(
    this._getIssueListUseCase,
    this._getOrderPoolUseCase,
    this._getIssueDetailUseCase,
    this._createIssueUseCase,
    this._executeIssueActionUseCase,
    this._updateIssueNotesUseCase,
    this._getExchangeListUseCase,
    this._getExchangeDetailUseCase,
    this._createExchangeFromIssueUseCase,
    this._executeExchangeActionUseCase,
    this._updateExchangeNotesUseCase,
    this._getRefundListUseCase,
    this._getRefundDetailUseCase,
    this._createRefundFromIssueUseCase,
    this._executeRefundActionUseCase,
    this._updateRefundNotesUseCase,
    this.errorStore,
  );

  final GetIssueListUseCase _getIssueListUseCase;
  final GetOrderPoolUseCase _getOrderPoolUseCase;
  final GetIssueDetailUseCase _getIssueDetailUseCase;
  final CreateIssueUseCase _createIssueUseCase;
  final ExecuteIssueActionUseCase _executeIssueActionUseCase;
  final UpdateIssueNotesUseCase _updateIssueNotesUseCase;

  final GetExchangeListUseCase _getExchangeListUseCase;
  final GetExchangeDetailUseCase _getExchangeDetailUseCase;
  final CreateExchangeFromIssueUseCase _createExchangeFromIssueUseCase;
  final ExecuteExchangeActionUseCase _executeExchangeActionUseCase;
  final UpdateExchangeNotesUseCase _updateExchangeNotesUseCase;

  final GetRefundListUseCase _getRefundListUseCase;
  final GetRefundDetailUseCase _getRefundDetailUseCase;
  final CreateRefundFromIssueUseCase _createRefundFromIssueUseCase;
  final ExecuteRefundActionUseCase _executeRefundActionUseCase;
  final UpdateRefundNotesUseCase _updateRefundNotesUseCase;

  final ErrorStore errorStore;

  List<IssueTicket> issueList = <IssueTicket>[];
  List<OrderComplaintCandidate> orderPool = <OrderComplaintCandidate>[];
  IssueTicket? selectedIssue;
  IssueFilterGroup issueFilterGroup = IssueFilterGroup.all;
  String issueSearchQuery = '';
  bool isLoadingIssues = false;

  List<ExchangeRequest> exchangeList = <ExchangeRequest>[];
  ExchangeRequest? selectedExchange;
  ExchangeFilterGroup exchangeFilterGroup = ExchangeFilterGroup.all;
  String exchangeSearchQuery = '';
  bool isLoadingExchanges = false;

  List<RefundRequest> refundList = <RefundRequest>[];
  RefundRequest? selectedRefund;
  RefundFilterGroup refundFilterGroup = RefundFilterGroup.all;
  String refundSearchQuery = '';
  bool isLoadingRefunds = false;

  Future<void> loadAll() async {
    await Future.wait([
      getOrderPool(),
      getIssues(),
      getExchanges(),
      getRefunds(),
    ]);
  }

  Future<void> getOrderPool() async {
    try {
      orderPool = await _getOrderPoolUseCase.call(params: null);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  List<IssueTicket> get filteredIssues {
    var items = issueList.where((item) => _matchesIssueFilter(item.status));
    final query = issueSearchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((item) {
        return item.id.toLowerCase().contains(query) ||
            item.orderId.toLowerCase().contains(query) ||
            item.customerName.toLowerCase().contains(query) ||
            item.subject.toLowerCase().contains(query);
      });
    }
    return items.toList();
  }

  List<ExchangeRequest> get filteredExchanges {
    var items =
        exchangeList.where((item) => _matchesExchangeFilter(item.status));
    final query = exchangeSearchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((item) {
        return item.id.toLowerCase().contains(query) ||
            item.orderId.toLowerCase().contains(query) ||
            item.customerName.toLowerCase().contains(query) ||
            item.reason.toLowerCase().contains(query);
      });
    }
    return items.toList();
  }

  List<RefundRequest> get filteredRefunds {
    var items = refundList.where((item) => _matchesRefundFilter(item.status));
    final query = refundSearchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((item) {
        return item.id.toLowerCase().contains(query) ||
            item.orderId.toLowerCase().contains(query) ||
            item.customerName.toLowerCase().contains(query) ||
            item.reason.toLowerCase().contains(query);
      });
    }
    return items.toList();
  }

  Future<void> getIssues() async {
    isLoadingIssues = true;
    try {
      issueList = await _getIssueListUseCase.call(params: null);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingIssues = false;
    }
  }

  Future<void> getIssueDetail(String id) async {
    try {
      selectedIssue = await _getIssueDetailUseCase.call(params: id);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<String?> createIssue({
    required String orderId,
    required String customerName,
    required String subject,
    required String description,
    required IssuePriority priority,
    required String channel,
  }) async {
    try {
      final id = await _createIssueUseCase.call(
        params: CreateIssueParams(
          orderId: orderId,
          customerName: customerName,
          subject: subject,
          description: description,
          priority: priority,
          channel: channel,
        ),
      );
      await getIssues();
      await getIssueDetail(id);
      return id;
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<void> executeIssueAction(String id, IssueAction action) async {
    try {
      await _executeIssueActionUseCase.call(
        params: ExecuteIssueActionParams(id: id, action: action),
      );
      await getIssueDetail(id);
      await getIssues();
      await getExchanges();
      await getRefunds();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<void> updateIssueNotes(String id, String notes) async {
    try {
      await _updateIssueNotesUseCase.call(
        params: UpdateIssueNotesParams(id: id, notes: notes),
      );
      await getIssueDetail(id);
      await getIssues();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<String?> createExchangeFromIssue({
    required String issueId,
    required String reason,
  }) async {
    try {
      final id = await _createExchangeFromIssueUseCase.call(
        params: CreateExchangeFromIssueParams(
          issueId: issueId,
          reason: reason,
        ),
      );
      await getIssueDetail(issueId);
      await getIssues();
      await getExchanges();
      return id;
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<void> getExchanges() async {
    isLoadingExchanges = true;
    try {
      exchangeList = await _getExchangeListUseCase.call(params: null);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingExchanges = false;
    }
  }

  Future<void> getExchangeDetail(String id) async {
    try {
      selectedExchange = await _getExchangeDetailUseCase.call(params: id);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<void> executeExchangeAction(String id, ExchangeAction action) async {
    try {
      await _executeExchangeActionUseCase.call(
        params: ExecuteExchangeActionParams(id: id, action: action),
      );
      await getExchangeDetail(id);
      await getExchanges();
      await getIssues();
      await getRefunds();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<void> updateExchangeNotes(String id, String notes) async {
    try {
      await _updateExchangeNotesUseCase.call(
        params: UpdateExchangeNotesParams(id: id, notes: notes),
      );
      await getExchangeDetail(id);
      await getExchanges();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<String?> createRefundFromIssue({
    required String issueId,
    required String reason,
    double? refundAmount,
  }) async {
    try {
      final id = await _createRefundFromIssueUseCase.call(
        params: CreateRefundFromIssueParams(
          issueId: issueId,
          reason: reason,
          refundAmount: refundAmount,
        ),
      );
      await getIssueDetail(issueId);
      await getIssues();
      await getRefunds();
      return id;
    } catch (e) {
      errorStore.errorMessage = e.toString();
      return null;
    }
  }

  Future<void> getRefunds() async {
    isLoadingRefunds = true;
    try {
      refundList = await _getRefundListUseCase.call(params: null);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingRefunds = false;
    }
  }

  Future<void> getRefundDetail(String id) async {
    try {
      selectedRefund = await _getRefundDetailUseCase.call(params: id);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<void> executeRefundAction(String id, RefundAction action) async {
    try {
      await _executeRefundActionUseCase.call(
        params: ExecuteRefundActionParams(id: id, action: action),
      );
      await getRefundDetail(id);
      await getRefunds();
      await getIssues();
      await getExchanges();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  Future<void> updateRefundNotes(String id, String notes) async {
    try {
      await _updateRefundNotesUseCase.call(
        params: UpdateRefundNotesParams(id: id, notes: notes),
      );
      await getRefundDetail(id);
      await getRefunds();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  List<IssueAction> availableIssueActions(IssueStatus status) {
    switch (status) {
      case IssueStatus.open:
        return [IssueAction.startInvestigating];
      case IssueStatus.investigating:
        return [
          IssueAction.requestCustomerInfo,
          IssueAction.createExchange,
          IssueAction.createRefund,
          IssueAction.resolveDirectly,
        ];
      case IssueStatus.waitingCustomer:
        return [IssueAction.resumeInvestigating];
      case IssueStatus.pendingExchange:
      case IssueStatus.pendingRefund:
        return [];
      case IssueStatus.resolved:
        return [IssueAction.closeIssue];
      case IssueStatus.closed:
        return [];
    }
  }

  List<ExchangeAction> availableExchangeActions(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.requested:
        return [
          ExchangeAction.approve,
          ExchangeAction.reject,
          ExchangeAction.cancel,
        ];
      case ExchangeStatus.approved:
        return [ExchangeAction.markAwaitingReturn];
      case ExchangeStatus.awaitingReturn:
        return [ExchangeAction.markInTransitBack, ExchangeAction.cancel];
      case ExchangeStatus.inTransitBack:
        return [ExchangeAction.markReceived];
      case ExchangeStatus.received:
        return [ExchangeAction.shipReplacement];
      case ExchangeStatus.replacementShipped:
        return [ExchangeAction.completeExchange];
      case ExchangeStatus.completed:
      case ExchangeStatus.rejected:
      case ExchangeStatus.cancelled:
        return [];
    }
  }

  List<RefundAction> availableRefundActions(RefundStatus status) {
    switch (status) {
      case RefundStatus.requested:
        return [
          RefundAction.approve,
          RefundAction.reject,
          RefundAction.cancel,
        ];
      case RefundStatus.approved:
        return [RefundAction.markAwaitingReturn];
      case RefundStatus.awaitingReturn:
        return [RefundAction.markInTransitBack, RefundAction.cancel];
      case RefundStatus.inTransitBack:
        return [RefundAction.markReceived];
      case RefundStatus.received:
        return [RefundAction.markRefundPending];
      case RefundStatus.refundPending:
        return [RefundAction.completeRefund];
      case RefundStatus.refunded:
      case RefundStatus.rejected:
      case RefundStatus.cancelled:
        return [];
    }
  }

  ExchangeRequest? findExchangeById(String? id) {
    if (id == null) return null;
    final idx = exchangeList.indexWhere((item) => item.id == id);
    return idx == -1 ? null : exchangeList[idx];
  }

  RefundRequest? findRefundById(String? id) {
    if (id == null) return null;
    final idx = refundList.indexWhere((item) => item.id == id);
    return idx == -1 ? null : refundList[idx];
  }

  IssueTicket? findIssueById(String? id) {
    if (id == null) return null;
    final idx = issueList.indexWhere((item) => item.id == id);
    return idx == -1 ? null : issueList[idx];
  }

  bool _matchesIssueFilter(IssueStatus status) {
    switch (issueFilterGroup) {
      case IssueFilterGroup.all:
        return true;
      case IssueFilterGroup.active:
        return status == IssueStatus.open ||
            status == IssueStatus.investigating ||
            status == IssueStatus.pendingExchange ||
            status == IssueStatus.pendingRefund;
      case IssueFilterGroup.waiting:
        return status == IssueStatus.waitingCustomer;
      case IssueFilterGroup.done:
        return status == IssueStatus.resolved || status == IssueStatus.closed;
    }
  }

  bool _matchesExchangeFilter(ExchangeStatus status) {
    switch (exchangeFilterGroup) {
      case ExchangeFilterGroup.all:
        return true;
      case ExchangeFilterGroup.active:
        return status == ExchangeStatus.requested ||
            status == ExchangeStatus.approved ||
            status == ExchangeStatus.received ||
            status == ExchangeStatus.replacementShipped;
      case ExchangeFilterGroup.waiting:
        return status == ExchangeStatus.awaitingReturn ||
            status == ExchangeStatus.inTransitBack;
      case ExchangeFilterGroup.done:
        return status == ExchangeStatus.completed ||
            status == ExchangeStatus.rejected ||
            status == ExchangeStatus.cancelled;
    }
  }

  bool _matchesRefundFilter(RefundStatus status) {
    switch (refundFilterGroup) {
      case RefundFilterGroup.all:
        return true;
      case RefundFilterGroup.active:
        return status == RefundStatus.requested ||
            status == RefundStatus.approved ||
            status == RefundStatus.received ||
            status == RefundStatus.refundPending;
      case RefundFilterGroup.waiting:
        return status == RefundStatus.awaitingReturn ||
            status == RefundStatus.inTransitBack;
      case RefundFilterGroup.done:
        return status == RefundStatus.refunded ||
            status == RefundStatus.rejected ||
            status == RefundStatus.cancelled;
    }
  }
}
