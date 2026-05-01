import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/dto/shared/paginated_response.dto.dart';

class SupplierApi {
  static const String _erpPath = '/erp';

  final DioClient _dioClient;
  final String _suppliersPath;
  final String _productsPath;

  SupplierApi(
    this._dioClient, {
    String suppliersPath = '$_erpPath/suppliers',
    String productsPath = '$_erpPath/products',
  })  : _suppliersPath = suppliersPath,
        _productsPath = productsPath;

  Future<PaginatedResponseDto> getSuppliers({
    String search = '',
    int page = 1,
    int pageSize = 10,
    bool? hasProducts,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (search.isNotEmpty) queryParameters['search'] = search;
    if (hasProducts != null) queryParameters['hasProducts'] = hasProducts;
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

    final response = await _dioClient.dio.get(
      _suppliersPath,
      queryParameters: queryParameters,
    );
    return PaginatedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
      pageFallback: page,
      pageSizeFallback: pageSize,
    );
  }

  Future<Map<String, dynamic>> getSupplierById(String id) async {
    final response = await _dioClient.dio.get(
      '$_suppliersPath/$id',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<PaginatedResponseDto> getSupplierProducts(
    String supplierId, {
    int page = 1,
    int pageSize = 10,
    String search = '',
  }) async {
    final response = await _dioClient.dio.get(
      '$_suppliersPath/$supplierId/products',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return PaginatedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
      pageFallback: page,
      pageSizeFallback: pageSize,
    );
  }

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> payload) async {
    final response = await _dioClient.dio.post(
      _suppliersPath,
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSupplier(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.patch(
      '$_suppliersPath/$id',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteSupplier(String id) async {
    await _dioClient.dio.delete('$_suppliersPath/$id');
  }

  Future<Map<String, dynamic>> addProductToSupplier(
    String productId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dioClient.dio.post(
      '$_productsPath/$productId/suppliers',
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
      '$_productsPath/$productId/suppliers/$supplierId',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> removeProductFromSupplier(
    String productId,
    String supplierId,
  ) async {
    await _dioClient.dio.delete(
      '$_productsPath/$productId/suppliers/$supplierId',
    );
  }

  Future<PaginatedResponseDto> searchProducts({
    String search = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (search.isNotEmpty) queryParameters['search'] = search;

    final response = await _dioClient.dio.get(
      _productsPath,
      queryParameters: queryParameters,
    );
    return PaginatedResponseDto.fromJson(
      response.data as Map<String, dynamic>,
      pageFallback: page,
      pageSizeFallback: pageSize,
    );
  }
}
