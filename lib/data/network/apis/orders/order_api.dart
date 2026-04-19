import 'dart:async';

import 'package:flutter/foundation.dart';
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
      debugPrint('OrderApi.getOrders error: $e');
      rethrow;
    }
  }

  /// Fetches a single order with its items and status history.
  Future<OrderDetailResponse> getOrderDetail(String id) async {
    try {
      final res = await _dioClient.dio.get(Endpoints.orderDetail(id));
      return OrderDetailResponse.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('OrderApi.getOrderDetail error: $e');
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
      debugPrint('OrderApi.updateOrderStatus error: $e');
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
      debugPrint('OrderApi.createOrLinkOrderShipment error: $e');
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
      debugPrint('OrderApi.getOrderShipmentTracking error: $e');
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
      debugPrint('OrderApi.getOrderShipmentsTracking error: $e');
      rethrow;
    }
  }

  Future<List<ShipmentLabelArtifactResponseDto>> getShipmentLabelArtifacts(
    String orderId,
    String shipmentId,
  ) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.orderShipmentLabels(orderId, shipmentId),
      );

      final data = res.data;
      if (data is! List<dynamic>) {
        return const <ShipmentLabelArtifactResponseDto>[];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(ShipmentLabelArtifactResponseDto.fromJson)
          .toList();
    } catch (e) {
      debugPrint('OrderApi.getShipmentLabelArtifacts error: $e');
      rethrow;
    }
  }

  Future<List<ShipmentPrintJobResponseDto>> getShipmentPrintJobs(
    String orderId,
    String shipmentId,
  ) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.orderShipmentPrintJobs(orderId, shipmentId),
      );

      final data = res.data;
      if (data is! List<dynamic>) {
        return const <ShipmentPrintJobResponseDto>[];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(ShipmentPrintJobResponseDto.fromJson)
          .toList();
    } catch (e) {
      debugPrint('OrderApi.getShipmentPrintJobs error: $e');
      rethrow;
    }
  }

  Future<ShipmentPrintJobResponseDto> createShipmentPrintJob(
    String orderId,
    String shipmentId, {
    String? artifactId,
    String artifactType = 'shipping_label',
    String format = 'pdf',
    String? printerName,
    String? printerCode,
    int copies = 1,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final req = <String, dynamic>{
        'artifactType': artifactType,
        'format': format,
        'copies': copies,
      };

      if (artifactId != null) {
        req['artifactId'] = artifactId;
      }
      if (printerName != null && printerName.isNotEmpty) {
        req['printerName'] = printerName;
      }
      if (printerCode != null && printerCode.isNotEmpty) {
        req['printerCode'] = printerCode;
      }
      if (payload != null) {
        req['payload'] = payload;
      }
      if (metadata != null) {
        req['metadata'] = metadata;
      }

      final res = await _dioClient.dio.post(
        Endpoints.orderShipmentPrintJobs(orderId, shipmentId),
        data: req,
      );

      return ShipmentPrintJobResponseDto.fromJson(
        res.data as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('OrderApi.createShipmentPrintJob error: $e');
      rethrow;
    }
  }

  Future<ShipmentPrintJobResponseDto> createShipmentPrintAttempt(
    String orderId,
    String shipmentId,
    String printJobId, {
    required String status,
    String? spoolJobId,
    String? errorCode,
    String? errorMessage,
    int? durationMs,
    Map<String, dynamic>? printerResponse,
  }) async {
    try {
      final req = <String, dynamic>{
        'status': status,
      };

      if (spoolJobId != null && spoolJobId.isNotEmpty) {
        req['spoolJobId'] = spoolJobId;
      }
      if (errorCode != null && errorCode.isNotEmpty) {
        req['errorCode'] = errorCode;
      }
      if (errorMessage != null && errorMessage.isNotEmpty) {
        req['errorMessage'] = errorMessage;
      }
      if (durationMs != null) {
        req['durationMs'] = durationMs;
      }
      if (printerResponse != null) {
        req['printerResponse'] = printerResponse;
      }

      final res = await _dioClient.dio.post(
        Endpoints.orderShipmentPrintAttempts(orderId, shipmentId, printJobId),
        data: req,
      );

      return ShipmentPrintJobResponseDto.fromJson(
        res.data as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('OrderApi.createShipmentPrintAttempt error: $e');
      rethrow;
    }
  }
}
