import 'dart:async';

import 'package:mobile_ai_erp/data/network/apis/order/order_api.dart';
import 'package:mobile_ai_erp/domain/entity/order/order.dart';
import 'package:mobile_ai_erp/domain/entity/order/return_request.dart';

abstract class OrderDataSource {
  Future<List<Order>> getOrderHistory({String? status, int? page, int? pageSize});
  Future<Order> getOrderDetails(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<ReturnRequest> submitReturnRequest(String orderId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> reorder(String orderId);
}

class OrderApiDataSource implements OrderDataSource {
  final OrderApi _orderApi;

  OrderApiDataSource(this._orderApi);

  @override
  Future<List<Order>> getOrderHistory({String? status, int? page, int? pageSize}) {
    return _orderApi.getOrderHistory(status: status, page: page, pageSize: pageSize);
  }

  @override
  Future<Order> getOrderDetails(String orderId) {
    return _orderApi.getOrderDetails(orderId);
  }

  @override
  Future<void> cancelOrder(String orderId) {
    return _orderApi.cancelOrder(orderId);
  }

  @override
  Future<ReturnRequest> submitReturnRequest(String orderId, Map<String, dynamic> data) {
    return _orderApi.submitReturnRequest(orderId, data);
  }

  @override
  Future<Map<String, dynamic>> reorder(String orderId) {
    return _orderApi.reorder(orderId);
  }
}