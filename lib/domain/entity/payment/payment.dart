import '../order/order.dart' show PaymentStatus;

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String paymentMethod;
  final String? provider;
  final String? transactionId;
  final PaymentStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.provider,
    this.transactionId,
    this.status = PaymentStatus.pending,
    this.note,
    required this.createdAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      amount: _parseDouble(json['amount']),
      paymentMethod: json['paymentMethod'] as String? ?? '',
      provider: json['provider'] as String?,
      transactionId: json['transactionId'] as String?,
      status: PaymentStatus.fromString(json['status'] as String?),
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }

  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    String? paymentMethod,
    String? provider,
    String? transactionId,
    PaymentStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      provider: provider ?? this.provider,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
