import '../../../domain/entity/storefront_order/order.dart';
import '../../../domain/entity/storefront_order/return_request.dart';
import '../../../domain/repository/account/order_repository.dart';
import '../../local/datasources/storefront_order/order_api_datasource.dart';

class OrderRepositoryImpl implements StorefrontOrderRepository {
  final OrderApiDataSource _dataSource;

  OrderRepositoryImpl(this._dataSource);

  @override
  Future<List<StorefrontOrder>> getOrderHistory({String? status, int? page, int? pageSize}) =>
      _dataSource.getOrderHistory(status: status, page: page, pageSize: pageSize);

  @override
  Future<StorefrontOrder> getOrderDetails(String orderId) => _dataSource.getOrderDetails(orderId);

  @override
  Future<void> cancelOrder(String orderId) => _dataSource.cancelOrder(orderId);

  @override
  Future<void> submitReturnRequest(String orderId, Map<String, dynamic> data) =>
      _dataSource.submitReturnRequest(orderId, data);

  @override
  Future<Map<String, dynamic>> reorder(String orderId) => _dataSource.reorder(orderId);

  @override
  Future<void> confirmOrder(String orderId) => _dataSource.confirmOrder(orderId);
}