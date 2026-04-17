import 'package:mobile_ai_erp/data/network/dto/product_supplier_link.dto.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier_product_link.dart';

class ProductSupplierMapper {
  static SupplierProductLink toDomain(ProductSupplierLinkDto dto) {
    return SupplierProductLink(
      supplierId: dto.supplierId,
      productId: dto.productId,
      productName: dto.productName,
      supplierSku: dto.supplierSku,
      costPrice: dto.costPrice,
      isPrimary: dto.isPrimary,
    );
  }

  static SupplierProductLink fromJson(Map<String, dynamic> json) {
    return toDomain(ProductSupplierLinkDto.fromJson(json));
  }

  static List<SupplierProductLink> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Transforms product objects with nested supplier links into SupplierProductLink entities.
  /// API returns full products; this extracts the supplier link for the given supplier.
  static List<SupplierProductLink> fromProductList(
    List<dynamic> products,
    String supplierId,
  ) {
    final links = <SupplierProductLink>[];
    for (final item in products) {
      final product = item as Map<String, dynamic>;
      final suppliers = product['suppliers'] as List<dynamic>? ?? [];

      // Find and map the supplier link for this supplier
      for (final supplierData in suppliers) {
        final supplier = supplierData as Map<String, dynamic>;
        if (supplier['supplierId'] == supplierId) {
          links.add(SupplierProductLink(
            supplierId: supplierId,
            productId: product['id'] as String,
            productName: product['name'] as String,
            supplierSku: supplier['supplierSku'] as String?,
            costPrice: (supplier['costPrice'] as num?)?.toDouble(),
            isPrimary: supplier['isPrimary'] as bool? ?? false,
          ));
          break;
        }
      }
    }
    return links;
  }
}
