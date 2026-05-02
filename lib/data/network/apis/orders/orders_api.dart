import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class OrdersApi {
  final DioClient _dioClient;

  OrdersApi(this._dioClient);

  // Get orders list from backend API
<<<<<<< HEAD
  Future<dynamic> getOrders({
    int pageSize = 20,
    int page = 1,
    String? secretKey,
    String? tenantId,
  }) async {
    try {
      final url = '${Endpoints.backendBaseUrl}/internal/erp/orders';

      final options = _buildOptions(
        secretKey: secretKey,
        tenantId: tenantId,
      );

      final response = await _dioClient.dio.get(
        url,
        queryParameters: {
          'pageSize': pageSize,
          'page': page,
        },
        options: options,
      );

      return response.data;
=======
  Future<dynamic> getOrders({int pageSize = 20, int page = 1}) async {
    try {
      final url = Endpoints.backendOrders();

      final options = _buildOptions();

      final response = await _dioClient.dio.get(
        url,
        queryParameters: {'pageSize': pageSize, 'page': page},
        options: options,
      );

      // Normalize result to a list when possible so callers don't need to
      // handle many different shapes. Keep compatibility by returning raw
      // data when it's not a list or map with items/data.
      final data = response.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final possible = data['data'] ?? data['items'] ?? data['orders'];
        if (possible is List) return possible;
      }
      return data;
>>>>>>> b0b620a2c4c97ddc3ba48344fa11bc1924107178
    } catch (e) {
      _logDioError('GET', '/internal/erp/orders', e);
      rethrow;
    }
  }

<<<<<<< HEAD
  Future<Map<String, dynamic>> getOrderDetail(
    String orderId, {
    String? secretKey,
    String? tenantId,
  }) async {
    try {
      final url = '${Endpoints.backendBaseUrl}/internal/erp/orders/$orderId';
      final options = _buildOptions(
        secretKey: secretKey,
        tenantId: tenantId,
      );

      final response = await _dioClient.dio.get(
        url,
        options: options,
      );
=======
  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final url = Endpoints.backendOrders(orderId);
      final options = _buildOptions();

      final response = await _dioClient.dio.get(url, options: options);
>>>>>>> b0b620a2c4c97ddc3ba48344fa11bc1924107178

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final dynamic inner = data['data'] ?? data['item'] ?? data['order'];
        if (inner is Map<String, dynamic>) {
          return inner;
        }
        return data;
      }

      return <String, dynamic>{};
    } catch (e) {
      _logDioError('GET', '/internal/erp/orders/$orderId', e);
      rethrow;
    }
  }

  Options _buildOptions({String? secretKey, String? tenantId}) {
<<<<<<< HEAD
    return Options(
      headers: {
        if (secretKey != null) 'X-Secret-Key': secretKey,
        if (tenantId != null) 'X-Tenant-Id': tenantId,
      },
    );
=======
    // By default rely on Dio interceptors (TenantHeaderInterceptor / AuthInterceptor)
    // to provide tenant/auth headers. Keep ability to override by passing
    // explicit headers via parameters if needed.
    final headers = <String, dynamic>{};
    if (secretKey != null && secretKey.isNotEmpty) {
      headers['X-Secret-Key'] = secretKey;
    }
    if (tenantId != null && tenantId.isNotEmpty) {
      headers['X-Tenant-Id'] = tenantId;
    }

    if (headers.isEmpty) return Options();

    return Options(headers: headers);
>>>>>>> b0b620a2c4c97ddc3ba48344fa11bc1924107178
  }

  void _logDioError(String method, String path, Object error) {
    if (error is DioException) {
      final response = error.response;
      final status = response?.statusCode;
      final data = response?.data;
      final message = error.message ?? 'Unknown error';
      debugPrint(
        'OrdersApi $method $path failed. Status=$status Message=$message Response=$data',
      );
      return;
    }

    debugPrint('OrdersApi $method $path failed. Error=$error');
  }
}
