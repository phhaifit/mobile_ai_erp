import 'dart:async';

import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_detail_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_list_response.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/shipment_tracking_response.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

/// API client for the ERP Orders endpoints.
class OrderApi {
  final DioClient _dioClient;

  OrderApi(this._dioClient);

  /// Fetches a paginated list of orders, optionally filtered by status.
  Future<OrderListResponse> getOrders({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};
      if (status != null) {
        queryParams['status'] = status;
      }

      final res = await _dioClient.dio.get(
        Endpoints.orders,
        queryParameters: queryParams,
      );
      return OrderListResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      print('OrderApi.getOrders error: $e');
      rethrow;
    }
  }

  /// Fetches a single order with its items and status history.
  Future<OrderDetailResponse> getOrderDetail(String id) async {
    try {
      final res = await _dioClient.dio.get(Endpoints.orderDetail(id));
      return OrderDetailResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      print('OrderApi.getOrderDetail error: $e');
      rethrow;
    }
  }

  /// Updates the lifecycle status of an order.
  ///
  /// Valid target statuses: `processing`, `shipped`, `delivered`, `cancelled`.
  Future<OrderDetailResponse> updateOrderStatus(
    String id,
    String status,
  ) async {
    try {
      final res = await _dioClient.dio.patch(
        Endpoints.orderStatus(id),
        data: {'status': status},
      );
      return OrderDetailResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      print('OrderApi.updateOrderStatus error: $e');
      rethrow;
    }
  }

  Future<ShipmentTrackingResponseDto> createOrLinkOrderShipment(
    String orderId, {
    List<Map<String, dynamic>>? items,
  }
  ) async {
    try {
      final payload = <String, dynamic>{};
      if (items != null && items.isNotEmpty) {
        payload['items'] = items;
      }

      final res = await _dioClient.dio.post(
        Endpoints.orderShipment(orderId),
        data: payload,
      );

      return ShipmentTrackingResponseDto.fromJson(
        res.data as Map<String, dynamic>,
      );
    } catch (e) {
      print('OrderApi.createOrLinkOrderShipment error: $e');
      rethrow;
    }
  }

  Future<ShipmentTrackingResponseDto> getOrderShipmentTracking(
    String orderId, {
    bool refresh = false,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.orderShipmentTracking(orderId),
        queryParameters: refresh ? {'refresh': 'true'} : null,
      );

      return ShipmentTrackingResponseDto.fromJson(
        res.data as Map<String, dynamic>,
      );
    } catch (e) {
      print('OrderApi.getOrderShipmentTracking error: $e');
      rethrow;
    }
  }

  Future<OrderShipmentsTrackingResponseDto> getOrderShipmentsTracking(
    String orderId, {
    bool refresh = false,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.orderShipmentsTracking(orderId),
        queryParameters: refresh ? {'refresh': 'true'} : null,
      );

      return OrderShipmentsTrackingResponseDto.fromJson(
        res.data as Map<String, dynamic>,
      );
    } catch (e) {
      print('OrderApi.getOrderShipmentsTracking error: $e');
      rethrow;
    }
  }
}
