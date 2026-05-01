class CustomerTransactionDto {
  final String id;
  final String orderId;
  final String status;
  final String amount;
  final String createdAt;

  CustomerTransactionDto({
    required this.id,
    required this.orderId,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory CustomerTransactionDto.fromJson(Map<String, dynamic> json) {
    return CustomerTransactionDto(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      amount: json['amount'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
