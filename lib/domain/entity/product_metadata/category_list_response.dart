import 'package:mobile_ai_erp/core/domain/model/pagination_meta.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

class CategoryListResponse {
  final List<Category> categories;
  final PaginationMeta meta;

  CategoryListResponse(this.categories, this.meta);

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'];
    final List<Category> categories = data.map((item) => Category.fromJson(item)).toList();
    final PaginationMeta meta = PaginationMeta.fromJson(json['meta']);
    return CategoryListResponse(categories, meta);
  }
}