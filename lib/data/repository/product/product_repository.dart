import 'package:mobile_ai_erp/domain/entity/product_detail/product_variant_detail.dart';

abstract class ProductRepository {
  Future<ProductVariantDetail> getVariantDetail(String variantId);
}
