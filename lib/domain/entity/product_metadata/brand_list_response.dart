// import 'package:mobile_ai_erp/core/domain/model/pagination_meta.dart';
// import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';

// class BrandListResponse {
//   final List<Brand> brands;
//   final PaginationMeta meta;

//   BrandListResponse(this.brands, this.meta);
//   factory BrandListResponse.fromJson(Map<String, dynamic> json) {
//     final List<dynamic> data = json['data'];
//     final List<Brand> brands = data.map((item) => Brand.fromJson(item)).toList();
//     final PaginationMeta meta = PaginationMeta.fromJson(json['meta']);
//     return BrandListResponse(brands, meta);
//   }
// }