import 'package:mobile_ai_erp/data/repository/product/product_repository_impl.dart';

abstract class ProductRepository {
  Future<ProductVariantDetail> getVariantDetail(String variantId);
}
