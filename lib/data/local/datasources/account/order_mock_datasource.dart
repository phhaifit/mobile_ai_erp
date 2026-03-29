import '../../../../domain/entity/order/order.dart';

class OrderMockDataSource {
  final List<Order> _mockOrders = [
    Order(
      id: 'ORD-2026-001',
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 5)),
      totalAmount: 1250000,
      shippingFee: 30000,
      shippingAddress: '227 Nguyen Van Cu, HCM',
      paymentMethod: 'COD',
      items: [
        OrderItem(
            id: 'item_1',
            productId: 'p_101',
            productName: 'Mechanical Keyboard',
            quantity: 1,
            price: 1250000,
            imageUrl: 'mock_url_here'),
      ],
    ),
    Order(
      id: 'ORD-2026-002',
      status: OrderStatus.pending,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      totalAmount: 450000,
      shippingFee: 15000,
      shippingAddress: '227 Nguyen Van Cu, HCM',
      paymentMethod: 'Bank Transfer',
      items: [
        OrderItem(
            id: 'item_2',
            productId: 'p_102',
            productName: 'Wireless Mouse',
            quantity: 1,
            price: 450000,
            imageUrl: 'mock_url_here'),
      ],
    ),
  ];

  Future<List<Order>> getOrderHistory() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return _mockOrders;
  }
}
