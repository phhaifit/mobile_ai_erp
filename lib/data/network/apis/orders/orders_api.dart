import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';

@Deprecated('Use OrderApi instead.')
class OrdersApi extends OrderApi {
  OrdersApi(DioClient dioClient) : super(dioClient);
}
