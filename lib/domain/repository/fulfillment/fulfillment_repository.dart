import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';

abstract class FulfillmentRepository {
  Future<List<FulfillmentOrder>> getOrders({FulfillmentStatus? status, int? page});
  Future<FulfillmentOrder?> getOrderById(String id);
  Future<void> updateOrderStatus(String id, FulfillmentStatus status);
}
