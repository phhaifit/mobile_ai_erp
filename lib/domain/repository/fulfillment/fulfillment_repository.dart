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
    List<CreateShipmentItemAllocation> items,
  });
  Future<ShipmentTrackingInfo?> getShipmentTracking(
    String orderId, {
    bool refresh = false,
  });
  Future<OrderShipmentsTrackingInfo?> getOrderShipmentsTracking(
    String orderId, {
    bool refresh = false,
  });
  Future<List<ShipmentLabelArtifact>> getShipmentLabelArtifacts(
    String orderId,
    String shipmentId,
  );
  Future<List<ShipmentPrintJob>> getShipmentPrintJobs(
    String orderId,
    String shipmentId,
  );
  Future<ShipmentPrintJob> createShipmentPrintJob(
    String orderId,
    String shipmentId, {
    String? artifactId,
    String artifactType,
    String format,
    String? printerName,
    String? printerCode,
    int copies,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? metadata,
  });
  Future<ShipmentPrintJob> createShipmentPrintAttempt(
    String orderId,
    String shipmentId,
    String printJobId, {
    required String status,
    String? spoolJobId,
    String? errorCode,
    String? errorMessage,
    int? durationMs,
    Map<String, dynamic>? printerResponse,
  });
}
