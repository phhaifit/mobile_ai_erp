import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';

class PostPurchaseDataSource {
  final List<IssueTicket> _issues = [
    IssueTicket(
      id: 'ISS-1001',
      orderId: 'ORD-23015',
      customerName: 'Nguyen Minh',
      subject: 'Damaged item on arrival',
      description: 'The left earcup is cracked and unusable.',
      status: IssueStatus.newIssue,
      priority: IssuePriority.high,
      channel: 'Email',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      assignee: 'Lan Tran',
      adminNotes: 'Customer sent photos. Awaiting warehouse confirmation.',
    ),
    IssueTicket(
      id: 'ISS-1002',
      orderId: 'ORD-22988',
      customerName: 'Le Hoang',
      subject: 'Missing accessories',
      description: 'Charging cable not included in the box.',
      status: IssueStatus.inReview,
      priority: IssuePriority.medium,
      channel: 'Chat',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      assignee: 'Khoa Vu',
      adminNotes: 'Offer partial refund if cable is unavailable.',
    ),
    IssueTicket(
      id: 'ISS-1003',
      orderId: 'ORD-22972',
      customerName: 'Pham Thu',
      subject: 'Late delivery complaint',
      description: 'Package is 4 days late compared to ETA.',
      status: IssueStatus.awaitingCustomer,
      priority: IssuePriority.low,
      channel: 'Phone',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      assignee: 'Minh Dao',
      adminNotes: 'Carrier delay due to storm. Follow up in 24h.',
    ),
    IssueTicket(
      id: 'ISS-1004',
      orderId: 'ORD-22890',
      customerName: 'Hoang An',
      subject: 'Refund not received',
      description: 'Refund approved but not reflected in bank account.',
      status: IssueStatus.resolved,
      priority: IssuePriority.high,
      channel: 'Email',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      assignee: 'Linh Pham',
      adminNotes: 'Bank transfer pending settlement.',
    ),
  ];

  final List<ReturnExchangeRequest> _returns = [
    ReturnExchangeRequest(
      id: 'RET-2001',
      orderId: 'ORD-23001',
      customerName: 'Tran Quang',
      reason: 'Wrong size delivered',
      status: ReturnStatus.requested,
      type: ReturnType.exchange,
      requestedAt: DateTime.now().subtract(const Duration(hours: 20)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 20)),
      items: [
        ReturnLineItem(
          sku: 'TSHIRT-BLK-M',
          name: 'Basic Tee - Black M',
          quantity: 1,
          price: 199000,
        ),
      ],
      exchangeSku: 'TSHIRT-BLK-L',
      notes: 'Customer requests size L replacement.',
      adminNotes: 'Awaiting stock confirmation.',
      linkedIssueId: 'ISS-1001',
    ),
    ReturnExchangeRequest(
      id: 'RET-2002',
      orderId: 'ORD-22940',
      customerName: 'Do Mai',
      reason: 'Product defective',
      status: ReturnStatus.inTransitBack,
      type: ReturnType.returnOnly,
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      items: [
        ReturnLineItem(
          sku: 'BLENDER-900',
          name: 'Kitchen Blender 900W',
          quantity: 1,
          price: 1299000,
        ),
      ],
      refundAmount: 1299000,
      adminNotes: 'Return label sent via email.',
      linkedIssueId: 'ISS-1002',
    ),
    ReturnExchangeRequest(
      id: 'RET-2003',
      orderId: 'ORD-22877',
      customerName: 'Bui Long',
      reason: 'Changed mind',
      status: ReturnStatus.refunded,
      type: ReturnType.returnOnly,
      requestedAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        ReturnLineItem(
          sku: 'SHOES-RUN-41',
          name: 'Running Shoes 41',
          quantity: 1,
          price: 899000,
        ),
      ],
      refundAmount: 899000,
      adminNotes: 'Refund completed via wallet.',
      linkedIssueId: 'ISS-1004',
    ),
  ];

  Future<List<IssueTicket>> getIssues() async {
    return List<IssueTicket>.from(_issues);
  }

  Future<IssueTicket?> getIssueById(String id) async {
    final idx = _issues.indexWhere((i) => i.id == id);
    return idx == -1 ? null : _issues[idx];
  }

  Future<void> updateIssueStatus(String id, IssueStatus status) async {
    final idx = _issues.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _issues[idx].status = status;
    _issues[idx].updatedAt = DateTime.now();
  }

  Future<List<ReturnExchangeRequest>> getReturns() async {
    return List<ReturnExchangeRequest>.from(_returns);
  }

  Future<ReturnExchangeRequest?> getReturnById(String id) async {
    final idx = _returns.indexWhere((r) => r.id == id);
    return idx == -1 ? null : _returns[idx];
  }

  Future<void> updateReturnStatus(String id, ReturnStatus status) async {
    final idx = _returns.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _returns[idx].status = status;
    _returns[idx].updatedAt = DateTime.now();
  }


  Future<void> linkIssueToReturn({required String issueId, required String returnId}) async {
    final issueIdx = _issues.indexWhere((i) => i.id == issueId);
    final returnIdx = _returns.indexWhere((r) => r.id == returnId);
    if (issueIdx == -1 || returnIdx == -1) return;
    _issues[issueIdx].linkedReturnId = returnId;
    _issues[issueIdx].updatedAt = DateTime.now();
    _returns[returnIdx].linkedIssueId = issueId;
    _returns[returnIdx].updatedAt = DateTime.now();
  }

  Future<void> updateIssueNotes(String id, String notes) async {
    final idx = _issues.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    _issues[idx].adminNotes = notes;
    _issues[idx].updatedAt = DateTime.now();
  }

  Future<void> updateReturnNotes(String id, String notes) async {
    final idx = _returns.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _returns[idx].adminNotes = notes;
    _returns[idx].updatedAt = DateTime.now();
  }

  Future<void> convertExchangeToRefund(String id) async {
    final idx = _returns.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final item = _returns[idx];
    if (item.type != ReturnType.exchange) return;
    item.type = ReturnType.returnOnly;
    item.status = ReturnStatus.approved;
    item.updatedAt = DateTime.now();
    item.adminNotes = (item.adminNotes ?? '') +
        (item.adminNotes == null || item.adminNotes!.isEmpty
            ? 'Converted to refund due to no replacement stock.'
            : '\nConverted to refund due to no replacement stock.');
  }

}

