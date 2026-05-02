class CustomerOrderItem {
  const CustomerOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  final String id;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.code,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingFee,
    required this.totalPrice,
    required this.createdAt,
    this.source,
    this.items = const [],
  });

  final String id;
  final String code;
  final String status;
  final String paymentStatus;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double totalPrice;
  final DateTime createdAt;
  final String? source;
  final List<CustomerOrderItem> items;
}
