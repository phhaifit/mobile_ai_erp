import 'dart:async';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/order/order.dart';
import 'package:mobile_ai_erp/domain/entity/order/return_request.dart';

class OrderApi {
  final DioClient _dioClient;

  OrderApi(this._dioClient);

  /// Get customer order history
  /// Get customer order history
  Future<List<Order>> getOrderHistory({String? status, int? page, int? pageSize}) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.customerOrders,
        queryParameters: {
          if (status != null) 'status': status,
          if (page != null) 'page': page,
          if (pageSize != null) 'pageSize': pageSize,
        },
      );
      
      // Unwrap the paginated 'data' key
      final List dataList = res.data['data'] ?? [];
      return dataList.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      print('❌ [OrderApi.getOrderHistory] Error: $e');
      rethrow;
    }
  }

  /// Get order details (NOTE: Backend endpoint needed)
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final res = await _dioClient.dio.get('${Endpoints.customerOrders}/$orderId');
      return Order.fromJson(res.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel order (NOTE: Backend endpoint needed)
  Future<void> cancelOrder(String orderId) async {
    try {
      await _dioClient.dio.patch('${Endpoints.customerOrders}/$orderId/cancel');
    } catch (e) {
      rethrow;
    }
  }

  /// Submit return request
  Future<void> submitReturnRequest(String orderId, Map<String, dynamic> data) async {
    try {
      // Hits the NestJS: @Post(':orderId/return')
      await _dioClient.dio.post(
        '${Endpoints.customerOrders}/$orderId/return',
        data: data, // This will be your SubmitReturnPayload mapped to JSON
      );
    } catch (e) {
      print('❌ [OrderApi.submitReturnRequest] Error: $e');
      rethrow;
    }
  }

  /// Re-order
  Future<Map<String, dynamic>> reorder(String orderId) async {
    try {
      // Hits the NestJS: @Post(':orderId/reorder')
      final response = await _dioClient.dio.post(
        '${Endpoints.customerOrders}/$orderId/reorder', 
      );
      return response.data; // Returns { message, cartId } from your backend
    } catch (e) {
      print('❌ [OrderApi.reorder] Error: $e');
      rethrow;
    }
  }

  /// Confirm order success
  Future<void> confirmOrder(String orderId) async {
    try {
      // Hits the new NestJS endpoint perfectly
      await _dioClient.dio.patch('${Endpoints.customerOrders}/$orderId/confirm');
    } catch (e) {
      print('❌ [OrderApi.confirmOrder] Error: $e');
      rethrow;
    }
  }
}