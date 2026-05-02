import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class StorefrontProductsApi {
  final DioClient _dioClient;

  StorefrontProductsApi(this._dioClient);

  Future<Map<String, dynamic>> getProductDetail(String id) async {
    final res = await _dioClient.dio.get(Endpoints.storefrontProductById(id));
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 10,
    String? categoryId,
    String? brandId,
    String? sortBy,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.storefrontProducts,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': categoryId,
        if (brandId != null && brandId.isNotEmpty) 'brandId': brandId,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getBrandProducts(
    String brandKey, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await _dioClient.dio.get(
      Endpoints.storefrontBrandProducts(brandKey),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getCategoryDetail(String categoryKey) async {
    final res = await _dioClient.dio.get(
      Endpoints.storefrontCategoryByKey(categoryKey),
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
