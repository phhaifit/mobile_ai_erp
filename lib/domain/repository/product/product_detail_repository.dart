import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_variant_detail.dart';

abstract class ProductDetailRepository {
  Future<ProductDetailPageData> getProductDetailPage(String productId);

  ProductVariantDetail? getCachedVariantDetail(String variantId);
}
