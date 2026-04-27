import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';

class StorefrontApi {
  StorefrontApi(this._dioClient);

  final DioClient _dioClient;

  Future<StorefrontHomeData> getHome() async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>('/storefront/home');
    return StorefrontHomeData.fromJson(response.data ?? const {});
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getProducts(
    StorefrontProductQuery query,
  ) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/storefront/products',
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginatedResponse(
      response.data ?? const {},
      StorefrontProduct.fromJson,
    );
  }

  Future<StorefrontFacets> getFacets(StorefrontProductQuery query) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/storefront/products/facets',
      queryParameters: query.toQueryParameters(),
    );
    return StorefrontFacets.fromJson(response.data ?? const {});
  }

  Future<StorefrontProductDetail> getProductDetail(String productId) async {
    final response =
        await _dioClient.dio.get<Map<String, dynamic>>('/storefront/products/$productId');
    return StorefrontProductDetail.fromJson(response.data ?? const {});
  }

  Future<List<StorefrontCategoryTreeNode>> getCategories() async {
    final response =
        await _dioClient.dio.get<List<dynamic>>('/storefront/categories');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(StorefrontCategoryTreeNode.fromJson)
        .toList();
  }

  Future<StorefrontCategoryDetail> getCategoryDetail(String categoryKey) async {
    final response = await _dioClient.dio
        .get<Map<String, dynamic>>('/storefront/categories/$categoryKey');
    return StorefrontCategoryDetail.fromJson(response.data ?? const {});
  }

  Future<List<StorefrontBrand>> getBrands() async {
    final response = await _dioClient.dio.get<List<dynamic>>('/storefront/products/brands');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(StorefrontBrand.fromJson)
        .toList();
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getBrandProducts(
    String brandKey,
    StorefrontProductQuery query,
  ) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/storefront/products/brands/$brandKey/products',
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginatedResponse(
      response.data ?? const {},
      StorefrontProduct.fromJson,
    );
  }

  Future<List<StorefrontCollection>> getCollections() async {
    final response =
        await _dioClient.dio.get<List<dynamic>>('/storefront/products/collections');
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(StorefrontCollection.fromJson)
        .toList();
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getCollectionProducts(
    String collectionSlug,
    StorefrontProductQuery query,
  ) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '/storefront/products/collections/$collectionSlug/products',
      queryParameters: query.toQueryParameters(),
    );
    return _parsePaginatedResponse(
      response.data ?? const {},
      StorefrontProduct.fromJson,
    );
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
}
