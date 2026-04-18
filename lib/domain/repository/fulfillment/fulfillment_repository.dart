import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';

abstract class FulfillmentRepository {
  Future<List<FulfillmentOrder>> getOrders({
    FulfillmentStatus? status,
    int? page,
  });
  Future<FulfillmentOrder?> getOrderById(String id);
  Future<void> updateOrderStatus(String id, FulfillmentStatus status);
  Future<ShipmentTrackingInfo> createOrLinkShipment(
    String orderId, {
    String? trackingCode,
    String? note,
  });
  Future<ShipmentTrackingInfo?> getShipmentTracking(
    String orderId, {
    bool refresh = false,
  });
}
