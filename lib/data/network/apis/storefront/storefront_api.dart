import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';

class StorefrontApi {
  StorefrontApi(this._dioClient);

  final DioClient _dioClient;

  Future<StorefrontHomeData> getHome() async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/storefront/home',
      );
      return StorefrontHomeData.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return const StorefrontHomeData.empty();
      }
      rethrow;
    }
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getProducts(
    StorefrontProductQuery query,
  ) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/storefront/products',
        queryParameters: query.toQueryParameters(),
      );
      return _parsePaginatedResponse(
        response.data ?? const {},
        StorefrontProduct.fromJson,
      );
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return _emptyPaginatedResponse<StorefrontProduct>(
          query.page,
          query.pageSize,
        );
      }
      rethrow;
    }
  }

  Future<StorefrontFacets> getFacets(StorefrontProductQuery query) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/storefront/products/facets',
        queryParameters: query.toQueryParameters(),
      );
      return StorefrontFacets.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return const StorefrontFacets.empty();
      }
      rethrow;
    }
  }

  Future<StorefrontProductDetail> getProductDetail(String productId) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/storefront/products/$productId',
    );
    return StorefrontProductDetail.fromJson(response.data ?? const {});
  }

  Future<List<StorefrontCategoryTreeNode>> getCategories() async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>(
        '/storefront/categories',
      );
      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontCategoryTreeNode.fromJson)
          .toList();
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<StorefrontCategoryDetail> getCategoryDetail(String categoryKey) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/storefront/categories/$categoryKey',
      );
      return StorefrontCategoryDetail.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return StorefrontCategoryDetail.fallback(categoryKey);
      }
      rethrow;
    }
  }

  Future<List<StorefrontBrand>> getBrands() async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>(
        '/storefront/products/brands',
      );
      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontBrand.fromJson)
          .toList();
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getBrandProducts(
    String brandKey,
    StorefrontProductQuery query,
  ) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/storefront/products/brands/$brandKey/products',
        queryParameters: query.toQueryParameters(),
      );
      return _parsePaginatedResponse(
        response.data ?? const {},
        StorefrontProduct.fromJson,
      );
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return _emptyPaginatedResponse<StorefrontProduct>(
          query.page,
          query.pageSize,
        );
      }
      rethrow;
    }
  }

  Future<List<StorefrontCollection>> getCollections() async {
    try {
      final response = await _dioClient.dio.get<List<dynamic>>(
        '/storefront/products/collections',
      );
      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StorefrontCollection.fromJson)
          .toList();
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getCollectionProducts(
    String collectionSlug,
    StorefrontProductQuery query,
  ) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '/storefront/products/collections/$collectionSlug/products',
        queryParameters: query.toQueryParameters(),
      );
      return _parsePaginatedResponse(
        response.data ?? const {},
        StorefrontProduct.fromJson,
      );
    } on DioException catch (error) {
      if (_isNotFound(error)) {
        return _emptyPaginatedResponse<StorefrontProduct>(
          query.page,
          query.pageSize,
        );
      }
      rethrow;
    }
  }

  StorefrontPaginatedResponse<T> _parsePaginatedResponse<T>(
    Map<String, dynamic> payload,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final meta = payload['meta'] as Map<String, dynamic>? ?? const {};
    return StorefrontPaginatedResponse<T>(
      data: (payload['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(mapper)
          .toList(),
      page: (meta['page'] as num?)?.toInt() ?? 1,
      pageSize: (meta['pageSize'] as num?)?.toInt() ?? 0,
      totalItems: (meta['totalItems'] as num?)?.toInt() ?? 0,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  StorefrontPaginatedResponse<T> _emptyPaginatedResponse<T>(
    int page,
    int pageSize,
  ) {
    return StorefrontPaginatedResponse<T>(
      data: const [],
      page: page,
      pageSize: pageSize,
      totalItems: 0,
      totalPages: 0,
    );
  }

  bool _isNotFound(DioException error) => error.response?.statusCode == 404;
}
