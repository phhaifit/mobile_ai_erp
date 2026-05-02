enum ExchangeStatus {
  requested,
  approved,
  awaitingReturn,
  inTransitBack,
  received,
  replacementShipped,
  completed,
  rejected,
  cancelled,
}

extension ExchangeStatusLabel on ExchangeStatus {
  String get displayName {
    switch (this) {
      case ExchangeStatus.requested:
        return 'Requested';
      case ExchangeStatus.approved:
        return 'Approved';
      case ExchangeStatus.awaitingReturn:
        return 'Awaiting Return';
      case ExchangeStatus.inTransitBack:
        return 'In Transit Back';
      case ExchangeStatus.received:
        return 'Received';
      case ExchangeStatus.replacementShipped:
        return 'Replacement Shipped';
      case ExchangeStatus.completed:
        return 'Completed';
      case ExchangeStatus.rejected:
        return 'Rejected';
      case ExchangeStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum ExchangeFilterGroup {
  all,
  active,
  waiting,
  done,
}

extension ExchangeFilterGroupLabel on ExchangeFilterGroup {
  String get displayName {
    switch (this) {
      case ExchangeFilterGroup.all:
        return 'All';
      case ExchangeFilterGroup.active:
        return 'Active';
      case ExchangeFilterGroup.waiting:
        return 'Waiting';
      case ExchangeFilterGroup.done:
        return 'Done';
    }
  }
}

enum ExchangeAction {
  approve,
  reject,
  cancel,
  markAwaitingReturn,
  markInTransitBack,
  markReceived,
  shipReplacement,
  completeExchange,
}

extension ExchangeActionLabel on ExchangeAction {
  String get displayName {
    switch (this) {
      case ExchangeAction.approve:
        return 'Approve';
      case ExchangeAction.reject:
        return 'Reject';
      case ExchangeAction.cancel:
        return 'Cancel';
      case ExchangeAction.markAwaitingReturn:
        return 'Mark Awaiting Return';
      case ExchangeAction.markInTransitBack:
        return 'Mark In Transit';
      case ExchangeAction.markReceived:
        return 'Mark Received';
      case ExchangeAction.shipReplacement:
        return 'Ship Replacement';
      case ExchangeAction.completeExchange:
        return 'Complete Exchange';
    }
  }
}

class ExchangeRequest {
  ExchangeRequest({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.reason,
    required this.status,
    required this.requestedAt,
    required this.updatedAt,
    this.adminNotes,
    this.linkedIssueId,
  });

  final String id;
  final String orderId;
  final String customerName;
  final String reason;
  ExchangeStatus status;
  final DateTime requestedAt;
  DateTime updatedAt;
  String? adminNotes;
  String? linkedIssueId;
}
