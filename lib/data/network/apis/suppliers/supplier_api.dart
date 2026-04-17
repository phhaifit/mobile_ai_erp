import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class SupplierApi {
  final DioClient _dioClient;

  SupplierApi(this._dioClient);

  Future<Map<String, dynamic>> getSuppliers({
    String search = '',
    int page = 1,
    int pageSize = 10,
    bool? includeInactive,
    bool? hasProducts,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (search.isNotEmpty) queryParameters['search'] = search;
    if (includeInactive != null) {
      queryParameters['includeInactive'] = includeInactive;
    }
    if (hasProducts != null) queryParameters['hasProducts'] = hasProducts;
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

    final response = await _dioClient.dio.get(
      Endpoints.suppliers,
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSupplierById(String id) async {
    final response = await _dioClient.dio.get(
      '${Endpoints.suppliers}/$id',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSupplierProducts(
    String supplierId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dioClient.dio.get(
      '${Endpoints.suppliers}/$supplierId/products',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> payload) async {
    final response = await _dioClient.dio.post(
      Endpoints.suppliers,
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSupplier(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.patch(
      '${Endpoints.suppliers}/$id',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteSupplier(String id) async {
    await _dioClient.dio.delete('${Endpoints.suppliers}/$id');
  }

  Future<Map<String, dynamic>> addProductToSupplier(
    String productId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.post(
      '${Endpoints.products}/$productId/suppliers',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProductSupplier(
    String productId,
    String supplierId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.patch(
      '${Endpoints.products}/$productId/suppliers/$supplierId',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> removeProductFromSupplier(
    String productId,
    String supplierId,
  ) async {
    await _dioClient.dio.delete(
      '${Endpoints.products}/$productId/suppliers/$supplierId',
    );
  }

  Future<Map<String, dynamic>> searchProducts({
    String search = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (search.isNotEmpty) queryParameters['search'] = search;

    final response = await _dioClient.dio.get(
      Endpoints.products,
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }
}
