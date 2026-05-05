class LoyaltyLedger {
  final String id;
  final int points;
  final String reason;
  final DateTime createdAt;
  final String? orderId;

  LoyaltyLedger({
    required this.id,
    required this.points,
    required this.reason,
    required this.createdAt,
    this.orderId,
  });

  factory LoyaltyLedger.fromJson(Map<String, dynamic> json) {
    return LoyaltyLedger(
      id: json['id'] as String,
      points: json['points'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      orderId: json['order_id'] as String?,
    );
  }
}