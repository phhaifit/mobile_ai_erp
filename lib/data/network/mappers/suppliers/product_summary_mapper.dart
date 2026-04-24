import 'package:mobile_ai_erp/data/network/dto/suppliers/product_summary.dto.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/product_summary.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/product_summary_supplier_ref.dart';

class ProductSummaryMapper {
  static ProductSummary toDomain(ProductSummaryDto dto) {
    return ProductSummary(
      id: dto.id,
      sku: dto.sku,
      name: dto.name,
      barcode: dto.barcode,
      description: dto.description,
      brandName: dto.brandName,
      categoryName: dto.categoryName,
      basePrice: dto.basePrice,
      sellingPrice: dto.sellingPrice,
      imageUrl: dto.imageUrl,
      suppliers: dto.suppliers.map(_mapSupplierRef).toList(),
    );
  }

  static ProductSummarySupplierRef _mapSupplierRef(
    ProductSummarySupplierRefDto dto,
  ) {
    return ProductSummarySupplierRef(
      supplierId: dto.supplierId,
      supplierSku: dto.supplierSku,
      isPrimary: dto.isPrimary,
    );
  }

  static ProductSummary fromJson(Map<String, dynamic> json) {
    return toDomain(ProductSummaryDto.fromJson(json));
  }

  static List<ProductSummary> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
