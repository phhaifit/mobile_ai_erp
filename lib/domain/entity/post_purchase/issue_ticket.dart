enum IssueStatus {
  newIssue,
  inReview,
  awaitingCustomer,
  resolved,
  closed,
}

extension IssueStatusLabel on IssueStatus {
  String get displayName {
    switch (this) {
      case IssueStatus.newIssue:
        return 'New';
      case IssueStatus.inReview:
        return 'In Review';
      case IssueStatus.awaitingCustomer:
        return 'Awaiting Customer';
      case IssueStatus.resolved:
        return 'Resolved';
      case IssueStatus.closed:
        return 'Closed';
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
    this.linkedReturnId,
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
  String? linkedReturnId;
}
