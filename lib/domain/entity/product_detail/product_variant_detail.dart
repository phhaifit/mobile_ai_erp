import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class ProductVariantDetail {
  final String productId;
  final String productName;
  final String brandName;
  final String categoryName;
  final String? imageUrl;
  final ProductVariant variant;

  const ProductVariantDetail({
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.categoryName,
    required this.imageUrl,
    required this.variant,
  });
}
