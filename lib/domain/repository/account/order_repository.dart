import '../../entity/storefront_order/order.dart';

abstract class StorefrontOrderRepository {
  Future<List<StorefrontOrder>> getOrderHistory({String? status, int? page, int? pageSize});
  Future<StorefrontOrder> getOrderDetails(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> submitReturnRequest(String orderId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> reorder(String orderId);
  Future<void> confirmOrder(String orderId);
}