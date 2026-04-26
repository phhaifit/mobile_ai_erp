import 'package:mobile_ai_erp/data/network/apis/brands/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/categories/category_api.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

/// This datasource is responsible for fetching product metadata such as brands and categories from the network.
/// Uses real network fetches from backend. Replaces the mock datasource in /lib/data/local/datasources/product_metadata/product_metadata_datasource.dart.
class ProductMetadataDatasource {
  final BrandApi _brandApi = BrandApi(RestClient());
  final CategoryApi _categoryApi = CategoryApi(RestClient());

  Future<List<Brand>> getBrands() async {
    return await _brandApi.getBrands().then((response) {
      if (response is List) {
        return response.map((item) => Brand.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    });
  }

  Future<List<Category>> getCategories() async {
    return await _categoryApi.getCategories().then((response) {
      if (response is List) {
        return response.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    });
  }
}