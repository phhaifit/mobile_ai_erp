import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/domain/entity/shared/paginated_result.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/product_summary.dart';
import 'package:mobile_ai_erp/data/network/mappers/suppliers/product_summary_mapper.dart';

class SupplierApi {
  final Dio _dio;
  final String _suppliersPath;
  final String _productsPath;

  SupplierApi(
    this._dio, {
    String suppliersPath = '/erp/suppliers',
    String productsPath = '/erp/products',
  })  : _suppliersPath = suppliersPath,
        _productsPath = productsPath;

  Future<Map<String, dynamic>> getSuppliers({
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

    final response = await _dio.get(
      _suppliersPath,
      queryParameters: queryParameters,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSupplierById(String id) async {
    final response = await _dio.get(
      '$_suppliersPath/$id',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSupplierProducts(
    String supplierId, {
    int page = 1,
    int pageSize = 10,
    String search = '',
  }) async {
    final response = await _dio.get(
      '$_suppliersPath/$supplierId/products',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> payload) async {
    final response = await _dio.post(
      _suppliersPath,
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSupplier(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.patch(
      '$_suppliersPath/$id',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteSupplier(String id) async {
    await _dio.delete('$_suppliersPath/$id');
  }

  Future<Map<String, dynamic>> addProductToSupplier(
    String productId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post(
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
    final response = await _dio.patch(
      '$_productsPath/$productId/suppliers/$supplierId',
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> removeProductFromSupplier(
    String productId,
    String supplierId,
  ) async {
    await _dio.delete(
      '$_productsPath/$productId/suppliers/$supplierId',
    );
  }

  Future<PaginatedResult<ProductSummary>> searchProducts({
    String search = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (search.isNotEmpty) queryParameters['search'] = search;

    final response = await _dio.get(
      _productsPath,
      queryParameters: queryParameters,
    );

    final data = response.data as Map<String, dynamic>;
    final products = (data['data'] as List<dynamic>?)
        ?.map((item) => ProductSummaryMapper.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    final meta = data['meta'] as Map<String, dynamic>?;
    return PaginatedResult(
      data: products,
      page: meta?['page'] as int? ?? page,
      pageSize: meta?['pageSize'] as int? ?? pageSize,
      totalItems: meta?['totalItems'] as int? ?? products.length,
      totalPages: meta?['totalPages'] as int? ?? 1,
    );
  }
}
