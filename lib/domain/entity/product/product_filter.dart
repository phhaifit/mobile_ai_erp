import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';

class ProductFilter {
  final String? searchQuery;
  final ProductStatus? status;
  final int? categoryId;
  final int? brandId;

  ProductFilter({
    this.searchQuery,
    this.status,
    this.categoryId,
    this.brandId,
  });

  bool matches(Map<String, dynamic> product) {
    // Check search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      final name = (product['name'] as String?)?.toLowerCase() ?? '';
      final sku = (product['sku'] as String?)?.toLowerCase() ?? '';
      final description = (product['description'] as String?)?.toLowerCase() ?? '';
      
      if (!name.contains(query) && 
          !sku.contains(query) && 
          !description.contains(query)) {
        return false;
      }
    }

    // Check status
    if (status != null) {
      if (product['status'] != status!.value) {
        return false;
      }
    }

    // Check category
    if (categoryId != null) {
      if (product['categoryId'] != categoryId) {
        return false;
      }
    }

    // Check brand
    if (brandId != null) {
      if (product['brandId'] != brandId) {
        return false;
      }
    }

    return true;
  }

  ProductFilter copyWith({
    String? searchQuery,
    ProductStatus? status,
    int? categoryId,
    int? brandId,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
    );
  }
}
