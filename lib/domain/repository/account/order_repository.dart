import '../../entity/order/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrderHistory({String? status, int? page, int? pageSize});
  Future<Order> getOrderDetails(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> submitReturnRequest(String orderId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> reorder(String orderId);
  Future<void> confirmOrder(String orderId);
}