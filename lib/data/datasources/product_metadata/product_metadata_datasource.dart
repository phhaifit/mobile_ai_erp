import 'dart:developer';

import 'package:mobile_ai_erp/data/network/apis/brands/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/categories/category_api.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_list_response.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

/// This datasource is responsible for fetching product metadata such as brands and categories from the network.
/// Uses real network fetches from backend. Replaces the mock datasource in /lib/data/local/datasources/product_metadata/product_metadata_datasource.dart.
class ProductMetadataDatasource {
  final BrandApi _brandApi = BrandApi();
  final CategoryApi _categoryApi = CategoryApi(RestClient());

  Future<BrandListResponse> getBrands([Map<String, String>? queryParameters]) async {
    try {
      final response = await _brandApi.getBrands(queryParameters);
      return BrandListResponse.fromJson(response);
    } catch (e) {
      log('Error fetching brands: $e');
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    return await _categoryApi.getCategories().then((response) {
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        return data.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    });
  }
}