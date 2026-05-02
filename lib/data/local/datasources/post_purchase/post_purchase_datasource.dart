import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/order_complaint_candidate.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';

class PostPurchaseDataSource {
  final List<OrderComplaintCandidate> _orderPool = const [
    OrderComplaintCandidate(
      orderId: 'ORD-23077',
      customerName: 'Pham An',
      preferredChannel: 'Phone',
    ),
    OrderComplaintCandidate(
      orderId: 'ORD-23068',
      customerName: 'Le Vy',
      preferredChannel: 'Phone',
    ),
    OrderComplaintCandidate(
      orderId: 'ORD-23061',
      customerName: 'Tran Gia Bao',
      preferredChannel: 'Hotline',
    ),
    OrderComplaintCandidate(
      orderId: 'ORD-23053',
      customerName: 'Nguyen Hai',
      preferredChannel: 'Store Frontdesk',
    ),
  ];

  final List<IssueTicket> _issues = [
    IssueTicket(
      id: 'ISS-1001',
      orderId: 'ORD-23015',
      customerName: 'Nguyen Minh',
      subject: 'Damaged item on arrival',
      description: 'Customer reported cracked headset on delivery.',
      status: IssueStatus.open,
      priority: IssuePriority.high,
      channel: 'Email',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 9)),
      assignee: 'Lan Tran',
      adminNotes: 'Newly created case, pending triage.',
    ),
    IssueTicket(
      id: 'ISS-1002',
      orderId: 'ORD-22988',
      customerName: 'Le Hoang',
      subject: 'Wrong size delivered',
      description: 'Requested size M but received size S.',
      status: IssueStatus.pendingExchange,
      priority: IssuePriority.medium,
      channel: 'Chat',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      assignee: 'Khoa Vu',
      adminNotes: 'Exchange flow started.',
      linkedExchangeId: 'EXC-3001',
    ),
    IssueTicket(
      id: 'ISS-1003',
      orderId: 'ORD-22972',
      customerName: 'Pham Thu',
      subject: 'Package delayed',
      description: 'Customer waiting for carrier update.',
      status: IssueStatus.waitingCustomer,
      priority: IssuePriority.low,
      channel: 'Phone',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 20)),
      assignee: 'Minh Dao',
      adminNotes: 'Asked customer to confirm delivery address.',
    ),
    IssueTicket(
      id: 'ISS-1004',
      orderId: 'ORD-22890',
      customerName: 'Hoang An',
      subject: 'Refund requested',
      description: 'Product defective after first use.',
      status: IssueStatus.pendingRefund,
      priority: IssuePriority.high,
      channel: 'Email',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 7)),
      assignee: 'Linh Pham',
      linkedRefundId: 'RFD-4001',
    ),
    IssueTicket(
      id: 'ISS-1005',
      orderId: 'ORD-22844',
      customerName: 'Tran Bao',
      subject: 'Exchange completed confirmation',
      description: 'Customer confirmed replacement received.',
      status: IssueStatus.resolved,
      priority: IssuePriority.medium,
      channel: 'Chat',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      assignee: 'Lan Tran',
      linkedExchangeId: 'EXC-3002',
    ),
  ];

  final List<ExchangeRequest> _exchanges = [
    ExchangeRequest(
      id: 'EXC-3001',
      orderId: 'ORD-22988',
      customerName: 'Le Hoang',
      reason: 'Wrong size delivered',
      status: ExchangeStatus.awaitingReturn,
      requestedAt: DateTime.now().subtract(const Duration(hours: 16)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      adminNotes: 'Waiting for customer handover to carrier.',
      linkedIssueId: 'ISS-1002',
    ),
    ExchangeRequest(
      id: 'EXC-3002',
      orderId: 'ORD-22844',
      customerName: 'Tran Bao',
      reason: 'Color mismatch',
      status: ExchangeStatus.completed,
      requestedAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      adminNotes: 'Completed successfully.',
      linkedIssueId: 'ISS-1005',
    ),
  ];

  final List<RefundRequest> _refunds = [
    RefundRequest(
      id: 'RFD-4001',
      orderId: 'ORD-22890',
      customerName: 'Hoang An',
      reason: 'Defective product',
      status: RefundStatus.refundPending,
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      refundAmount: 1299000,
      adminNotes: 'Finance queued transfer.',
      linkedIssueId: 'ISS-1004',
    ),
  ];

  Future<List<OrderComplaintCandidate>> getOrderPool() async {
    return List<OrderComplaintCandidate>.from(_orderPool);
  }

  Future<List<IssueTicket>> getIssues() async {
    return List<IssueTicket>.from(_issues);
  }

  Future<IssueTicket?> getIssueById(String id) async {
    final idx = _issues.indexWhere((i) => i.id == id);
    return idx == -1 ? null : _issues[idx];
  }

  Future<String> createIssue({
    required String orderId,
    required String customerName,
    required String subject,
    required String description,
    IssuePriority priority = IssuePriority.medium,
    String channel = 'Manual',
  }) async {
    final now = DateTime.now();
    final id = _nextId(prefix: 'ISS', currentIds: _issues.map((e) => e.id));
    final issue = IssueTicket(
      id: id,
      orderId: orderId.trim(),
      customerName: customerName.trim(),
      subject: subject.trim(),
      description: description.trim(),
      status: IssueStatus.open,
      priority: priority,
      channel: channel.trim().isEmpty ? 'Manual' : channel.trim(),
      createdAt: now,
      updatedAt: now,
      adminNotes: '',
    );
    _issues.insert(0, issue);
    return id;
  }

  Future<void> executeIssueAction(String id, IssueAction action) async {
    final issue = _findIssue(id);
    final nextStatus = _nextIssueStatus(issue.status, action);
    if (nextStatus == null) {
      throw StateError(
        'Invalid issue action ${action.name} from ${issue.status.name}',
      );
    }
    if (nextStatus == IssueStatus.closed && issue.status != IssueStatus.resolved) {
      throw StateError('Issue can only be closed after resolved.');
    }
    issue.status = nextStatus;
    issue.updatedAt = DateTime.now();
  }

  Future<void> updateIssueNotes(String id, String notes) async {
    final issue = _findIssue(id);
    issue.adminNotes = notes;
    issue.updatedAt = DateTime.now();
  }

  Future<List<ExchangeRequest>> getExchanges() async {
    return List<ExchangeRequest>.from(_exchanges);
  }

  Future<ExchangeRequest?> getExchangeById(String id) async {
    final idx = _exchanges.indexWhere((e) => e.id == id);
    return idx == -1 ? null : _exchanges[idx];
  }

  Future<String> createExchangeFromIssue({
    required String issueId,
    required String reason,
  }) async {
    final issue = _findIssue(issueId);
    if (issue.status != IssueStatus.investigating) {
      throw StateError('Exchange can only be created from investigating issue.');
    }
    if (_hasActiveChild(issue)) {
      throw StateError('Issue already has an active child action.');
    }

    final now = DateTime.now();
    final id = _nextId(prefix: 'EXC', currentIds: _exchanges.map((e) => e.id));
    final exchange = ExchangeRequest(
      id: id,
      orderId: issue.orderId,
      customerName: issue.customerName,
      reason: reason.trim().isEmpty ? issue.subject : reason.trim(),
      status: ExchangeStatus.requested,
      requestedAt: now,
      updatedAt: now,
      adminNotes: 'Created from issue ${issue.id}.',
      linkedIssueId: issue.id,
    );
    _exchanges.insert(0, exchange);

    issue.linkedExchangeId = id;
    issue.linkedRefundId = null;
    issue.status = IssueStatus.pendingExchange;
    issue.updatedAt = now;

    return id;
  }

  Future<void> executeExchangeAction(String id, ExchangeAction action) async {
    final exchange = _findExchange(id);
    final nextStatus = _nextExchangeStatus(exchange.status, action);
    if (nextStatus == null) {
      throw StateError(
        'Invalid exchange action ${action.name} from ${exchange.status.name}',
      );
    }

    final now = DateTime.now();
    exchange.status = nextStatus;
    exchange.updatedAt = now;

    if (exchange.linkedIssueId == null) return;
    final issue = _findIssue(exchange.linkedIssueId!);

    if (nextStatus == ExchangeStatus.completed) {
      issue.status = IssueStatus.resolved;
      issue.updatedAt = now;
      return;
    }

    if (nextStatus == ExchangeStatus.rejected ||
        nextStatus == ExchangeStatus.cancelled) {
      issue.status = IssueStatus.investigating;
      if (issue.linkedExchangeId == exchange.id) {
        issue.linkedExchangeId = null;
      }
      issue.updatedAt = now;
      return;
    }

    issue.status = IssueStatus.pendingExchange;
    issue.updatedAt = now;
  }

  Future<void> updateExchangeNotes(String id, String notes) async {
    final exchange = _findExchange(id);
    exchange.adminNotes = notes;
    exchange.updatedAt = DateTime.now();
  }

  Future<List<RefundRequest>> getRefunds() async {
    return List<RefundRequest>.from(_refunds);
  }

  Future<RefundRequest?> getRefundById(String id) async {
    final idx = _refunds.indexWhere((r) => r.id == id);
    return idx == -1 ? null : _refunds[idx];
  }

  Future<String> createRefundFromIssue({
    required String issueId,
    required String reason,
    double? refundAmount,
  }) async {
    final issue = _findIssue(issueId);
    if (issue.status != IssueStatus.investigating) {
      throw StateError('Refund can only be created from investigating issue.');
    }
    if (_hasActiveChild(issue)) {
      throw StateError('Issue already has an active child action.');
    }

    final now = DateTime.now();
    final id = _nextId(prefix: 'RFD', currentIds: _refunds.map((r) => r.id));
    final refund = RefundRequest(
      id: id,
      orderId: issue.orderId,
      customerName: issue.customerName,
      reason: reason.trim().isEmpty ? issue.subject : reason.trim(),
      status: RefundStatus.requested,
      requestedAt: now,
      updatedAt: now,
      refundAmount: refundAmount,
      adminNotes: 'Created from issue ${issue.id}.',
      linkedIssueId: issue.id,
    );
    _refunds.insert(0, refund);

    issue.linkedRefundId = id;
    issue.linkedExchangeId = null;
    issue.status = IssueStatus.pendingRefund;
    issue.updatedAt = now;

    return id;
  }

  Future<void> executeRefundAction(String id, RefundAction action) async {
    final refund = _findRefund(id);
    final nextStatus = _nextRefundStatus(refund.status, action);
    if (nextStatus == null) {
      throw StateError(
        'Invalid refund action ${action.name} from ${refund.status.name}',
      );
    }

    final now = DateTime.now();
    refund.status = nextStatus;
    refund.updatedAt = now;

    if (refund.linkedIssueId == null) return;
    final issue = _findIssue(refund.linkedIssueId!);

    if (nextStatus == RefundStatus.refunded) {
      issue.status = IssueStatus.resolved;
      issue.updatedAt = now;
      return;
    }

    if (nextStatus == RefundStatus.rejected ||
        nextStatus == RefundStatus.cancelled) {
      issue.status = IssueStatus.investigating;
      if (issue.linkedRefundId == refund.id) {
        issue.linkedRefundId = null;
      }
      issue.updatedAt = now;
      return;
    }

    issue.status = IssueStatus.pendingRefund;
    issue.updatedAt = now;
  }

  Future<void> updateRefundNotes(String id, String notes) async {
    final refund = _findRefund(id);
    refund.adminNotes = notes;
    refund.updatedAt = DateTime.now();
  }

  bool _hasActiveChild(IssueTicket issue) {
    if (issue.linkedExchangeId != null) {
      final idx = _exchanges.indexWhere((e) => e.id == issue.linkedExchangeId);
      if (idx != -1 && !_isExchangeTerminal(_exchanges[idx].status)) {
        return true;
      }
    }
    if (issue.linkedRefundId != null) {
      final idx = _refunds.indexWhere((r) => r.id == issue.linkedRefundId);
      if (idx != -1 && !_isRefundTerminal(_refunds[idx].status)) {
        return true;
      }
    }
    return false;
  }

  bool _isExchangeTerminal(ExchangeStatus status) {
    return status == ExchangeStatus.completed ||
        status == ExchangeStatus.rejected ||
        status == ExchangeStatus.cancelled;
  }

  bool _isRefundTerminal(RefundStatus status) {
    return status == RefundStatus.refunded ||
        status == RefundStatus.rejected ||
        status == RefundStatus.cancelled;
  }

  IssueStatus? _nextIssueStatus(IssueStatus current, IssueAction action) {
    switch (current) {
      case IssueStatus.open:
        if (action == IssueAction.startInvestigating) {
          return IssueStatus.investigating;
        }
        return null;
      case IssueStatus.investigating:
        if (action == IssueAction.requestCustomerInfo) {
          return IssueStatus.waitingCustomer;
        }
        if (action == IssueAction.resolveDirectly) {
          return IssueStatus.resolved;
        }
        return null;
      case IssueStatus.waitingCustomer:
        if (action == IssueAction.resumeInvestigating) {
          return IssueStatus.investigating;
        }
        return null;
      case IssueStatus.pendingExchange:
      case IssueStatus.pendingRefund:
        return null;
      case IssueStatus.resolved:
        if (action == IssueAction.closeIssue) {
          return IssueStatus.closed;
        }
        return null;
      case IssueStatus.closed:
        return null;
    }
  }

  ExchangeStatus? _nextExchangeStatus(
    ExchangeStatus current,
    ExchangeAction action,
  ) {
    switch (current) {
      case ExchangeStatus.requested:
        if (action == ExchangeAction.approve) return ExchangeStatus.approved;
        if (action == ExchangeAction.reject) return ExchangeStatus.rejected;
        if (action == ExchangeAction.cancel) return ExchangeStatus.cancelled;
        return null;
      case ExchangeStatus.approved:
        if (action == ExchangeAction.markAwaitingReturn) {
          return ExchangeStatus.awaitingReturn;
        }
        return null;
      case ExchangeStatus.awaitingReturn:
        if (action == ExchangeAction.markInTransitBack) {
          return ExchangeStatus.inTransitBack;
        }
        if (action == ExchangeAction.cancel) return ExchangeStatus.cancelled;
        return null;
      case ExchangeStatus.inTransitBack:
        if (action == ExchangeAction.markReceived) return ExchangeStatus.received;
        return null;
      case ExchangeStatus.received:
        if (action == ExchangeAction.shipReplacement) {
          return ExchangeStatus.replacementShipped;
        }
        return null;
      case ExchangeStatus.replacementShipped:
        if (action == ExchangeAction.completeExchange) {
          return ExchangeStatus.completed;
        }
        return null;
      case ExchangeStatus.completed:
      case ExchangeStatus.rejected:
      case ExchangeStatus.cancelled:
        return null;
    }
  }

  RefundStatus? _nextRefundStatus(RefundStatus current, RefundAction action) {
    switch (current) {
      case RefundStatus.requested:
        if (action == RefundAction.approve) return RefundStatus.approved;
        if (action == RefundAction.reject) return RefundStatus.rejected;
        if (action == RefundAction.cancel) return RefundStatus.cancelled;
        return null;
      case RefundStatus.approved:
        if (action == RefundAction.markAwaitingReturn) {
          return RefundStatus.awaitingReturn;
        }
        return null;
      case RefundStatus.awaitingReturn:
        if (action == RefundAction.markInTransitBack) {
          return RefundStatus.inTransitBack;
        }
        if (action == RefundAction.cancel) return RefundStatus.cancelled;
        return null;
      case RefundStatus.inTransitBack:
        if (action == RefundAction.markReceived) return RefundStatus.received;
        return null;
      case RefundStatus.received:
        if (action == RefundAction.markRefundPending) {
          return RefundStatus.refundPending;
        }
        return null;
      case RefundStatus.refundPending:
        if (action == RefundAction.completeRefund) return RefundStatus.refunded;
        return null;
      case RefundStatus.refunded:
      case RefundStatus.rejected:
      case RefundStatus.cancelled:
        return null;
    }
  }

  IssueTicket _findIssue(String id) {
    final idx = _issues.indexWhere((i) => i.id == id);
    if (idx == -1) throw StateError('Issue not found: $id');
    return _issues[idx];
  }

  ExchangeRequest _findExchange(String id) {
    final idx = _exchanges.indexWhere((e) => e.id == id);
    if (idx == -1) throw StateError('Exchange not found: $id');
    return _exchanges[idx];
  }

  RefundRequest _findRefund(String id) {
    final idx = _refunds.indexWhere((r) => r.id == id);
    if (idx == -1) throw StateError('Refund not found: $id');
    return _refunds[idx];
  }

  String _nextId({required String prefix, required Iterable<String> currentIds}) {
    var max = 0;
    final pattern = RegExp('^$prefix-(\\d+)\$');
    for (final id in currentIds) {
      final match = pattern.firstMatch(id);
      if (match == null) continue;
      final value = int.tryParse(match.group(1) ?? '');
      if (value != null && value > max) {
        max = value;
      }
    }
    return '$prefix-${max + 1}';
  }
}
