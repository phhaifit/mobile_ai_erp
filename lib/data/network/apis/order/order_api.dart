import 'dart:async';

import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/order/order.dart';
import 'package:mobile_ai_erp/domain/entity/order/return_request.dart';

class OrderApi {
  final DioClient _dioClient;

  OrderApi(this._dioClient);

  /// Get customer order history
  Future<List<Order>> getOrderHistory({String? status, int? page, int? pageSize}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['pageSize'] = pageSize;

      final res = await _dioClient.dio.get(
        Endpoints.customerOrders,
        queryParameters: queryParams,
      );
      final List data = res.data['data'] ?? res.data;
      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      throw e;
    }
  }

  /// Get order details
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final res = await _dioClient.dio.get('${Endpoints.customerOrders}/$orderId');
      return Order.fromJson(res.data);
    } catch (e) {
      throw e;
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _dioClient.dio.patch('${Endpoints.customerOrders}/$orderId/cancel');
    } catch (e) {
      throw e;
    }
  }

  /// Submit return request
  Future<ReturnRequest> submitReturnRequest(String orderId, Map<String, dynamic> data) async {
    try {
      final res = await _dioClient.dio.post(
        '${Endpoints.customerOrders}/$orderId/return',
        data: data,
      );
      return ReturnRequest.fromJson(res.data);
    } catch (e) {
      throw e;
    }
  }

  /// Re-order (create new order from existing)
  Future<Map<String, dynamic>> reorder(String orderId) async {
    try {
      final res = await _dioClient.dio.post('${Endpoints.customerOrders}/$orderId/reorder');
      return res.data;
    } catch (e) {
      throw e;
    }
  }
}