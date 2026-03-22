enum ReturnStatus { pending, approved, rejected }

class ReturnRequest {
  final String id;
  final String orderId;
  final String reason;
  final String details;
  final ReturnStatus status;
  final DateTime createdAt;

  ReturnRequest({
    required this.id,
    required this.orderId,
    required this.reason,
    required this.details,
    this.status = ReturnStatus.pending,
    required this.createdAt,
  });
}