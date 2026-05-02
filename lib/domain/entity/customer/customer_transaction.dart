class CustomerTransaction {
  const CustomerTransaction({
    required this.id,
    required this.orderId,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String status;
  final double amount;
  final DateTime createdAt;
}
