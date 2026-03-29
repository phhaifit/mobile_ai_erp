enum IssueStatus {
  open,
  investigating,
  waitingCustomer,
  pendingExchange,
  pendingRefund,
  resolved,
  closed,
}

extension IssueStatusLabel on IssueStatus {
  String get displayName {
    switch (this) {
      case IssueStatus.open:
        return 'Open';
      case IssueStatus.investigating:
        return 'Investigating';
      case IssueStatus.waitingCustomer:
        return 'Waiting Customer';
      case IssueStatus.pendingExchange:
        return 'Pending Exchange';
      case IssueStatus.pendingRefund:
        return 'Pending Refund';
      case IssueStatus.resolved:
        return 'Resolved';
      case IssueStatus.closed:
        return 'Closed';
    }
  }
}

enum IssueFilterGroup {
  all,
  active,
  waiting,
  done,
}

extension IssueFilterGroupLabel on IssueFilterGroup {
  String get displayName {
    switch (this) {
      case IssueFilterGroup.all:
        return 'All';
      case IssueFilterGroup.active:
        return 'Active';
      case IssueFilterGroup.waiting:
        return 'Waiting';
      case IssueFilterGroup.done:
        return 'Done';
    }
  }
}

enum IssueAction {
  startInvestigating,
  requestCustomerInfo,
  createExchange,
  createRefund,
  resolveDirectly,
  resumeInvestigating,
  closeIssue,
}

extension IssueActionLabel on IssueAction {
  String get displayName {
    switch (this) {
      case IssueAction.startInvestigating:
        return 'Start Investigating';
      case IssueAction.requestCustomerInfo:
        return 'Request Customer Info';
      case IssueAction.createExchange:
        return 'Create Exchange';
      case IssueAction.createRefund:
        return 'Create Refund';
      case IssueAction.resolveDirectly:
        return 'Resolve Directly';
      case IssueAction.resumeInvestigating:
        return 'Resume Investigating';
      case IssueAction.closeIssue:
        return 'Close Issue';
    }
  }
}

enum IssuePriority {
  low,
  medium,
  high,
}

extension IssuePriorityLabel on IssuePriority {
  String get displayName {
    switch (this) {
      case IssuePriority.low:
        return 'Low';
      case IssuePriority.medium:
        return 'Medium';
      case IssuePriority.high:
        return 'High';
    }
  }
}

class IssueTicket {
  IssueTicket({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.channel,
    required this.createdAt,
    required this.updatedAt,
    this.assignee,
    this.adminNotes,
    this.linkedExchangeId,
    this.linkedRefundId,
  });

  final String id;
  final String orderId;
  final String customerName;
  final String subject;
  final String description;
  IssueStatus status;
  IssuePriority priority;
  final String channel;
  final DateTime createdAt;
  DateTime updatedAt;
  final String? assignee;
  String? adminNotes;
  String? linkedExchangeId;
  String? linkedRefundId;
}
