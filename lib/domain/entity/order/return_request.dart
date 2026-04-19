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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'reason': reason,
      'details': details,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      reason: json['reason'] ?? '',
      details: json['details'] ?? '',
      status: _parseReturnStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static ReturnStatus _parseReturnStatus(dynamic status) {
    if (status == null) return ReturnStatus.pending;
    final statusStr = status.toString().toLowerCase();
    return ReturnStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr,
      orElse: () => ReturnStatus.pending,
    );
  }
}
