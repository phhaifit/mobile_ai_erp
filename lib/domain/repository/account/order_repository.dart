import '../../entity/order/order.dart';

abstract class OrderRepository {
  Future<OrderListResult> getOrderHistory({int page = 1, int pageSize = 10});
  Future<Order> getOrderById(String id);
}

class OrderListResult {
  final List<Order> orders;
  final int total;
  final int page;
  final int pageSize;

  OrderListResult({
    required this.orders,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
