import '../../entity/order/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrderHistory();
}