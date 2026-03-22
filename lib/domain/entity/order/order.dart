enum OrderStatus { pending, shipped, delivered, canceled }

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });
}

class Order {
  final String id;
  final OrderStatus status;
  final DateTime date;
  final double totalAmount;
  final double shippingFee;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.date,
    required this.totalAmount,
    required this.shippingFee,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
  });
}