import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/storefront_order/order_api.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/storefront_order/order.dart';
import 'package:mobile_ai_erp/domain/entity/storefront_order/return_request.dart';

abstract class OrderDataSource {
  Future<List<StorefrontOrder>> getOrderHistory({String? status, int? page, int? pageSize});
  Future<StorefrontOrder> getOrderDetails(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> submitReturnRequest(String orderId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> reorder(String orderId);
}

class OrderApiDataSource implements OrderDataSource {
  final StorefrontOrderApi _orderApi;
  final SharedPreferenceHelper _prefs;

  OrderApiDataSource(this._orderApi, this._prefs);

  @override
  Future<List<StorefrontOrder>> getOrderHistory({String? status, int? page, int? pageSize}) async {
    try {
      final customerId = await _prefs.getCustomerId();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Customer ID not found. User may not be logged in.');
      }
      return await _orderApi.getOrderHistory();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StorefrontOrder> getOrderDetails(String orderId) {
    return _orderApi.getOrderDetails(orderId);
  }

  @override
  Future<void> cancelOrder(String orderId) {
    return _orderApi.cancelOrder(orderId);
  }

  @override
  Future<Map<String, dynamic>> reorder(String orderId) {
    return _orderApi.reorder(orderId);
  }

  @override
  Future<void> submitReturnRequest(String orderId, Map<String, dynamic> data) {
    return _orderApi.submitReturnRequest(orderId, data);
  }

  @override
  Future<void> confirmOrder(String orderId) {
    return _orderApi.confirmOrder(orderId);
  }
}