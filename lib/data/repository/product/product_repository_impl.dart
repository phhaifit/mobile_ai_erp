import 'package:mobile_ai_erp/data/repository/product/product_repository.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_variant_detail.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_detail_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDetailRepository _productDetailRepository;

  ProductRepositoryImpl(this._productDetailRepository);

  @override
  Future<ProductVariantDetail> getVariantDetail(String variantId) async {
    final variantDetail = _productDetailRepository.getCachedVariantDetail(
      variantId,
    );
    if (variantDetail == null) {
      throw Exception(
        'Variant not loaded from storefront product detail: $variantId',
      );
    }
    return variantDetail;
  }
}
