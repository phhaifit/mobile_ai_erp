import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';

abstract class FulfillmentRepository {
  Future<List<FulfillmentOrder>> getOrders();
  Future<FulfillmentOrder?> getOrderById(String id);
  Future<void> updateOrderStatus(String id, FulfillmentStatus status);
  Future<void> updateItemPickedQty(String orderId, String itemId, int qty);
  Future<void> addPackage(String orderId, PackageInfo package);
  Future<void> updatePackage(String orderId, PackageInfo package);
}
