import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_detail_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/shipment_tracking_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_list_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class FulfillmentRepositoryImpl extends FulfillmentRepository {
  final OrderApi _orderApi;

  FulfillmentRepositoryImpl(this._orderApi);

  // ─── Public API ───────────────────────────────────────────────────────

  @override
  Future<List<FulfillmentOrder>> getOrders({
    FulfillmentStatus? status,
    int? page,
  }) async {
    final response = await _orderApi.getOrders(
      status: status?.apiValue,
      page: page ?? 1,
    );
    return response.data.map(_mapSummaryToEntity).toList();
  }

  @override
  Future<FulfillmentOrder?> getOrderById(String id) async {
    try {
      final response = await _orderApi.getOrderDetail(id);
      return _mapDetailToEntity(response);
    } catch (e) {
      // Return null if order is not found (404)
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String id, FulfillmentStatus status) async {
    await _orderApi.updateOrderStatus(id, status.apiValue);
  }

  @override
  Future<ShipmentTrackingInfo> createOrLinkShipment(
    String orderId, {
    List<CreateShipmentItemAllocation> items = const [],
  }) async {
    final response = await _orderApi.createOrLinkOrderShipment(
      orderId,
      items: items
          .map(
            (item) => {
              'orderItemId': item.orderItemId,
              'quantity': item.quantity,
            },
          )
          .toList(),
    );

    return _mapShipmentToEntity(response);
  }

  @override
  Future<ShipmentTrackingInfo?> getShipmentTracking(
    String orderId, {
    bool refresh = false,
  }) async {
    try {
      final response = await _orderApi.getOrderShipmentTracking(
        orderId,
        refresh: refresh,
      );

      return _mapShipmentToEntity(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<OrderShipmentsTrackingInfo?> getOrderShipmentsTracking(
    String orderId, {
    bool refresh = false,
  }) async {
    try {
      final response = await _orderApi.getOrderShipmentsTracking(
        orderId,
        refresh: refresh,
      );

      return OrderShipmentsTrackingInfo(
        orderId: response.orderId,
        shipments: response.shipments.map(_mapShipmentToEntity).toList(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  // ─── Mappers ──────────────────────────────────────────────────────────

  FulfillmentOrder _mapSummaryToEntity(OrderSummaryDto dto) {
    return FulfillmentOrder(
      id: dto.id,
      code: dto.code,
      customerName: dto.customerName ?? 'Unknown Customer',
      source: 'API',
      status:
          FulfillmentStatus.fromApiString(dto.status) ??
          FulfillmentStatus.pending,
      paymentStatus: dto.paymentStatus,
      createdAt: DateTime.parse(dto.createdAt),
      items: [],
      totalAmount: double.tryParse(dto.totalAmount) ?? 0,
    );
  }

  FulfillmentOrder _mapDetailToEntity(OrderDetailResponse response) {
    final order = response.order;

    return FulfillmentOrder(
      id: order.id,
      code: order.code,
      customerName: order.customer?.name ?? order.shippingName ?? 'Unknown',
      customerPhone: order.customer?.phone ?? order.shippingPhone,
      shippingAddress: order.shippingAddress,
      shippingProvince: order.shippingProvince,
      shippingDistrict: order.shippingDistrict,
      shippingWard: order.shippingWard,
      source: order.source,
      status:
          FulfillmentStatus.fromApiString(order.status) ??
          FulfillmentStatus.pending,
      paymentStatus: order.paymentStatus,
      createdAt: DateTime.parse(order.createdAt),
      updatedAt: DateTime.parse(order.updatedAt),
      items: response.items.map(_mapItemToEntity).toList(),
      trackingEvents: response.statusLogs.map(_mapLogToEntity).toList(),
      subtotal: double.tryParse(order.subtotal) ?? 0,
      discountAmount: double.tryParse(order.discountAmount) ?? 0,
      taxAmount: double.tryParse(order.taxAmount) ?? 0,
      shippingFee: double.tryParse(order.shippingFee) ?? 0,
      totalAmount: double.tryParse(order.totalAmount) ?? 0,
      notes: order.note,
    );
  }

  FulfillmentItem _mapItemToEntity(OrderItemDto dto) {
    return FulfillmentItem(
      id: dto.id,
      productName: dto.productName,
      sku: dto.sku,
      quantity: dto.quantity,
      unitPrice: double.tryParse(dto.unitPrice) ?? 0,
      totalPrice: double.tryParse(dto.totalPrice) ?? 0,
      productId: dto.productId,
      variantId: dto.variantId,
    );
  }

  TrackingEvent _mapLogToEntity(OrderStatusLogDto dto) {
    return TrackingEvent(
      id: dto.id,
      oldStatus: FulfillmentStatus.fromApiString(dto.oldStatus),
      newStatus:
          FulfillmentStatus.fromApiString(dto.newStatus) ??
          FulfillmentStatus.pending,
      note: dto.note,
      changedAt: DateTime.parse(dto.changedAt),
      changedByName: dto.changedBy?.name,
    );
  }

  ShipmentTrackingInfo _mapShipmentToEntity(ShipmentTrackingResponseDto dto) {
    return ShipmentTrackingInfo(
      id: dto.id,
      orderId: dto.orderId,
      shipmentNumber: dto.shipmentNumber,
      provider: dto.provider,
      trackingCode: dto.trackingCode,
      status: dto.status,
      rawStatus: dto.rawStatus,
      latestNote: dto.latestNote,
      estimatedDelivery: _tryParseDate(dto.estimatedDelivery),
      syncedAt: _tryParseDate(dto.syncedAt),
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
      items: dto.items
          .map(
            (item) => ShipmentItemAllocation(
              id: item.id,
              orderItemId: item.orderItemId,
              quantity: item.quantity,
            ),
          )
          .toList(),
      events: dto.events.map(_mapShipmentEventToEntity).toList(),
    );
  }

  ShipmentTrackingEvent _mapShipmentEventToEntity(
    ShipmentTrackingEventDto dto,
  ) {
    return ShipmentTrackingEvent(
      id: dto.id,
      status: dto.status,
      description: dto.description,
      location: dto.location,
      eventTime: DateTime.parse(dto.eventTime),
    );
  }

  DateTime? _tryParseDate(String? input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    return DateTime.tryParse(input);
  }
}
