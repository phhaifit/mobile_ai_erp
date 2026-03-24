import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_return_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_return_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/link_issue_to_return_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_return_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/convert_exchange_to_refund_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_return_status_usecase.dart';
import 'package:mobx/mobx.dart';

part 'post_purchase_store.g.dart';

class PostPurchaseStore = _PostPurchaseStore with _$PostPurchaseStore;

abstract class _PostPurchaseStore with Store {
  _PostPurchaseStore(
    this._getIssueListUseCase,
    this._getIssueDetailUseCase,
    this._updateIssueStatusUseCase,
    this._updateIssueNotesUseCase,
    this._linkIssueToReturnUseCase,
    this._getReturnListUseCase,
    this._getReturnDetailUseCase,
    this._updateReturnStatusUseCase,
    this._updateReturnNotesUseCase,
    this._convertExchangeToRefundUseCase,
    this.errorStore,
  );

  final GetIssueListUseCase _getIssueListUseCase;
  final GetIssueDetailUseCase _getIssueDetailUseCase;
  final UpdateIssueStatusUseCase _updateIssueStatusUseCase;
  final UpdateIssueNotesUseCase _updateIssueNotesUseCase;
  final LinkIssueToReturnUseCase _linkIssueToReturnUseCase;
  final GetReturnListUseCase _getReturnListUseCase;
  final GetReturnDetailUseCase _getReturnDetailUseCase;
  final UpdateReturnStatusUseCase _updateReturnStatusUseCase;
  final UpdateReturnNotesUseCase _updateReturnNotesUseCase;
  final ConvertExchangeToRefundUseCase _convertExchangeToRefundUseCase;
  final ErrorStore errorStore;

  @observable
  ObservableList<IssueTicket> issueList = ObservableList<IssueTicket>();

  @observable
  IssueTicket? selectedIssue;

  @observable
  IssueStatus? issueStatusFilter;

  @observable
  bool isLoadingIssues = false;

  @observable
  String issueSearchQuery = '';

  @observable
  ObservableList<ReturnExchangeRequest> returnList =
      ObservableList<ReturnExchangeRequest>();

  @observable
  ReturnExchangeRequest? selectedReturn;

  @observable
  ReturnStatus? returnStatusFilter;

  @observable
  ReturnType? returnTypeFilter;

  @observable
  bool isLoadingReturns = false;

  @observable
  String returnSearchQuery = '';

  @computed
  List<IssueTicket> get filteredIssues {
    Iterable<IssueTicket> items = issueList;
    if (issueStatusFilter != null) {
      items = items.where((i) => i.status == issueStatusFilter);
    }
    final q = issueSearchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((i) =>
          i.id.toLowerCase().contains(q) ||
          i.orderId.toLowerCase().contains(q) ||
          i.customerName.toLowerCase().contains(q));
    }
    return items.toList();
  }

  @computed
  List<ReturnExchangeRequest> get filteredReturns {
    Iterable<ReturnExchangeRequest> items = returnList;
    if (returnStatusFilter != null) {
      items = items.where((r) => r.status == returnStatusFilter);
    }
    if (returnTypeFilter != null) {
      items = items.where((r) => r.type == returnTypeFilter);
    }
    final q = returnSearchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((r) =>
          r.id.toLowerCase().contains(q) ||
          r.orderId.toLowerCase().contains(q) ||
          r.customerName.toLowerCase().contains(q));
    }
    return items.toList();
  }

  @action
  Future<void> getIssues() async {
    isLoadingIssues = true;
    try {
      final issues = await _getIssueListUseCase.call(params: null);
      issueList = ObservableList.of(issues);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingIssues = false;
    }
  }

  @action
  Future<void> getIssueDetail(String id) async {
    try {
      selectedIssue = await _getIssueDetailUseCase.call(params: id);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  Future<void> updateIssueStatus(String id, IssueStatus status) async {
    try {
      await _updateIssueStatusUseCase.call(
        params: UpdateIssueStatusParams(id: id, status: status),
      );
      await getIssueDetail(id);
      await getIssues();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  void setIssueStatusFilter(IssueStatus? status) {
    issueStatusFilter = status;
  }

  @action
  Future<void> getReturns() async {
    isLoadingReturns = true;
    try {
      final returns = await _getReturnListUseCase.call(params: null);
      returnList = ObservableList.of(returns);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isLoadingReturns = false;
    }
  }

  @action
  Future<void> getReturnDetail(String id) async {
    try {
      selectedReturn = await _getReturnDetailUseCase.call(params: id);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  Future<void> updateReturnStatus(String id, ReturnStatus status) async {
    try {
      await _updateReturnStatusUseCase.call(
        params: UpdateReturnStatusParams(id: id, status: status),
      );
      await getReturnDetail(id);
      await getReturns();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  void setReturnStatusFilter(ReturnStatus? status) {
    returnStatusFilter = status;
  }

  @action
  void setReturnTypeFilter(ReturnType? type) {
    returnTypeFilter = type;
  }


  @action
  void setIssueSearchQuery(String value) {
    issueSearchQuery = value;
  }

  @action
  void setReturnSearchQuery(String value) {
    returnSearchQuery = value;
  }

  @action
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

  @action
  Future<void> linkIssueToReturn(String issueId, String returnId) async {
    try {
      await _linkIssueToReturnUseCase.call(
        params: LinkIssueToReturnParams(issueId: issueId, returnId: returnId),
      );
      await getIssueDetail(issueId);
      await getReturnDetail(returnId);
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  Future<void> updateReturnNotes(String id, String notes) async {
    try {
      await _updateReturnNotesUseCase.call(
        params: UpdateReturnNotesParams(id: id, notes: notes),
      );
      await getReturnDetail(id);
      await getReturns();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }

  @action
  Future<void> convertExchangeToRefund(String id) async {
    try {
      await _convertExchangeToRefundUseCase.call(params: id);
      await getReturnDetail(id);
      await getReturns();
    } catch (e) {
      errorStore.errorMessage = e.toString();
    }
  }
}
