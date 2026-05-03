import '../../../domain/entity/order/order.dart';
import '../../../domain/repository/account/order_repository.dart';
import '../../network/apis/storefront/storefront_orders_api.dart';

class OrderRepositoryImpl implements OrderRepository {
  final StorefrontOrdersApi _api;

  OrderRepositoryImpl(this._api);

  @override
  Future<OrderListResult> getOrderHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    final result = await _api.getOrders(page: page, pageSize: pageSize);
    return OrderListResult(
      orders: result.orders,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
  }

  @override
  Future<Order> getOrderById(String id) => _api.getOrderById(id);
}
