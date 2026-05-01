import 'dart:developer';

import 'package:mobile_ai_erp/data/network/apis/brands/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/categories/category_api.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_list_response.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_list_response.dart';

/// This datasource is responsible for fetching product metadata such as brands and categories from the network.
/// Uses real network fetches from backend. Replaces the mock datasource in /lib/data/local/datasources/product_metadata/product_metadata_datasource.dart.
class ProductMetadataDatasource {
  final BrandApi _brandApi = BrandApi();
  final CategoryApi _categoryApi = CategoryApi();

  Future<BrandListResponse> getBrands([Map<String, String>? queryParameters]) async {
    try {
      final response = await _brandApi.getBrands(queryParameters);
      return BrandListResponse.fromJson(response);
    } catch (e) {
      log('Error fetching brands: $e');
      rethrow;
    }
  }

  Future<CategoryListResponse> getCategories([Map<String, String>? queryParameters]) async {
    try {
      final response = await _categoryApi.getCategories(queryParameters);
      return CategoryListResponse.fromJson(response);
    } catch (e) {
      log('Error fetching categories: $e');
      rethrow;
    }
  }
}