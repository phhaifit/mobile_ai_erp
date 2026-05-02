import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/order/order.dart';

class StorefrontOrdersApi {
  final DioClient _dioClient;

  StorefrontOrdersApi(this._dioClient);

  /// GET /storefront/orders?page=1&pageSize=10
  Future<StorefrontOrdersResult> getOrders({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.storefrontOrders,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = res.data as Map<String, dynamic>;
    final ordersList = (data['data'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Order.fromJson)
            .toList() ??
        [];
    final meta = data['meta'] as Map<String, dynamic>?;
    return StorefrontOrdersResult(
      orders: ordersList,
      total: meta?['total'] as int? ?? ordersList.length,
      page: meta?['page'] as int? ?? page,
      pageSize: meta?['pageSize'] as int? ?? pageSize,
    );
  }

  /// GET /storefront/orders/:id
  Future<Order> getOrderById(String id) async {
    final res =
        await _dioClient.dio.get(Endpoints.storefrontOrderById(id));
    return Order.fromJson(res.data as Map<String, dynamic>);
  }
}

class StorefrontOrdersResult {
  final List<Order> orders;
  final int total;
  final int page;
  final int pageSize;

  StorefrontOrdersResult({
    required this.orders,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
