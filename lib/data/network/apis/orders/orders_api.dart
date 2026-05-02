import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class OrdersApi {
  final DioClient _dioClient;

  OrdersApi(this._dioClient);

  // Get orders list from backend API
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
    } catch (e) {
      _logDioError('GET', '/internal/erp/orders', e);
      rethrow;
    }
  }

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
    return Options(
      headers: {
        if (secretKey != null) 'X-Secret-Key': secretKey,
        if (tenantId != null) 'X-Tenant-Id': tenantId,
      },
    );
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
