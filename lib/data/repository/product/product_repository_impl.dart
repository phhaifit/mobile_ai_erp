// MOCK REPO (using for cart, dev implement this file can replace this mock repo)

import 'package:mobile_ai_erp/data/repository/product/product_repository.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/presentation/product_detail/data/mock_product_data.dart';

class ProductVariantDetail {
  final String productId;
  final String productName;
  final String brandName;
  final String categoryName;
  final String? imageUrl;
  final ProductVariant variant;

  ProductVariantDetail({
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.categoryName,
    required this.imageUrl,
    required this.variant,
  });
}

class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<ProductVariantDetail> getVariantDetail(String variantId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final product = MockProductData.sampleProduct;

    final variant = product.variants.firstWhere(
      (v) => v.id == variantId,
      orElse: () => throw Exception('Variant not found: $variantId'),
    );

    return ProductVariantDetail(
      productId: product.id,
      productName: product.name,
      brandName: product.brandName,
      categoryName: product.categoryName,
      imageUrl: product.media.isNotEmpty ? product.media.first.url : null,
      variant: variant,
    );
  }
}
