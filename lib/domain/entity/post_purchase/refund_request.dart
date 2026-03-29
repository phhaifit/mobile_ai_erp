enum RefundStatus {
  requested,
  approved,
  awaitingReturn,
  inTransitBack,
  received,
  refundPending,
  refunded,
  rejected,
  cancelled,
}

extension RefundStatusLabel on RefundStatus {
  String get displayName {
    switch (this) {
      case RefundStatus.requested:
        return 'Requested';
      case RefundStatus.approved:
        return 'Approved';
      case RefundStatus.awaitingReturn:
        return 'Awaiting Return';
      case RefundStatus.inTransitBack:
        return 'In Transit Back';
      case RefundStatus.received:
        return 'Received';
      case RefundStatus.refundPending:
        return 'Refund Pending';
      case RefundStatus.refunded:
        return 'Refunded';
      case RefundStatus.rejected:
        return 'Rejected';
      case RefundStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum RefundFilterGroup {
  all,
  active,
  waiting,
  done,
}

extension RefundFilterGroupLabel on RefundFilterGroup {
  String get displayName {
    switch (this) {
      case RefundFilterGroup.all:
        return 'All';
      case RefundFilterGroup.active:
        return 'Active';
      case RefundFilterGroup.waiting:
        return 'Waiting';
      case RefundFilterGroup.done:
        return 'Done';
    }
  }
}

enum RefundAction {
  approve,
  reject,
  cancel,
  markAwaitingReturn,
  markInTransitBack,
  markReceived,
  markRefundPending,
  completeRefund,
}

extension RefundActionLabel on RefundAction {
  String get displayName {
    switch (this) {
      case RefundAction.approve:
        return 'Approve';
      case RefundAction.reject:
        return 'Reject';
      case RefundAction.cancel:
        return 'Cancel';
      case RefundAction.markAwaitingReturn:
        return 'Mark Awaiting Return';
      case RefundAction.markInTransitBack:
        return 'Mark In Transit';
      case RefundAction.markReceived:
        return 'Mark Received';
      case RefundAction.markRefundPending:
        return 'Mark Refund Pending';
      case RefundAction.completeRefund:
        return 'Complete Refund';
    }
  }
}

class RefundRequest {
  RefundRequest({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.reason,
    required this.status,
    required this.requestedAt,
    required this.updatedAt,
    this.refundAmount,
    this.adminNotes,
    this.linkedIssueId,
  });

  final String id;
  final String orderId;
  final String customerName;
  final String reason;
  RefundStatus status;
  final DateTime requestedAt;
  DateTime updatedAt;
  double? refundAmount;
  String? adminNotes;
  String? linkedIssueId;
}
