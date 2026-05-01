import 'package:mobile_ai_erp/data/network/dto/suppliers/product_supplier_link.dto.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier_product_link.dart';

class ProductSupplierMapper {
  static SupplierProductLink toDomain(ProductSupplierLinkDto dto) {
    return SupplierProductLink(
      supplierId: dto.supplierId,
      productId: dto.productId,
      productName: dto.productName,
      productSku: dto.productSku,
      productBarcode: dto.productBarcode,
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
}
