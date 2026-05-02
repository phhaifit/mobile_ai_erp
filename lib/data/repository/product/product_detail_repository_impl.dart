import 'package:mobile_ai_erp/data/network/apis/storefront_products_api.dart';
import 'package:mobile_ai_erp/data/repository/product/storefront_product_mapper.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_variant_detail.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_detail_repository.dart';

class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final StorefrontProductsApi _api;
  final Map<String, ProductVariantDetail> _variantCache = {};

  ProductDetailRepositoryImpl(this._api);

  @override
  Future<ProductDetailPageData> getProductDetailPage(String productId) async {
    final productJson = await _api.getProductDetail(productId);
    final product = StorefrontProductMapper.productDetailFromJson(productJson);
    _cacheProductVariants(product);

    final relatedProducts = await _loadRelatedProducts(product);
    final brandProducts = await _loadBrandProducts(product);
    final categoryDetail = await _loadCategoryDetail(product);

    return ProductDetailPageData(
      product: product,
      relatedProducts: relatedProducts,
      brandProducts: brandProducts,
      categoryDetail: categoryDetail,
    );
  }

  @override
  ProductVariantDetail? getCachedVariantDetail(String variantId) {
    return _variantCache[variantId];
  }

  Future<List<StorefrontProductSummary>> _loadRelatedProducts(
    ProductDetail product,
  ) async {
    final categoryId = product.categoryId;
    if (categoryId == null || categoryId.isEmpty) return const [];

    return _safeList(() async {
      final json = await _api.getProducts(
        categoryId: categoryId,
        pageSize: 8,
        sortBy: 'popular',
      );
      return StorefrontProductMapper.productSummariesFromPaginatedJson(
        json,
      ).where((summary) => summary.id != product.id).toList();
    });
  }

  Future<List<StorefrontProductSummary>> _loadBrandProducts(
    ProductDetail product,
  ) async {
    final brandKey = product.brandId;
    if (brandKey == null || brandKey.isEmpty) return const [];

    return _safeList(() async {
      final json = await _api.getBrandProducts(brandKey, pageSize: 8);
      return StorefrontProductMapper.productSummariesFromPaginatedJson(
        json,
      ).where((summary) => summary.id != product.id).toList();
    });
  }

  Future<StorefrontCategoryDetail?> _loadCategoryDetail(
    ProductDetail product,
  ) async {
    final categoryKey = product.categoryId;
    if (categoryKey == null || categoryKey.isEmpty) return null;

    try {
      final json = await _api.getCategoryDetail(categoryKey);
      return StorefrontProductMapper.categoryDetailFromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<List<StorefrontProductSummary>> _safeList(
    Future<List<StorefrontProductSummary>> Function() load,
  ) async {
    try {
      return await load();
    } catch (_) {
      return const [];
    }
  }

  void _cacheProductVariants(ProductDetail product) {
    final imageUrl = product.media.isNotEmpty ? product.media.first.url : null;
    for (final variant in product.variants) {
      _variantCache[variant.id] = ProductVariantDetail(
        productId: product.id,
        productName: product.name,
        brandName: product.brandName,
        categoryName: product.categoryName,
        imageUrl: imageUrl,
        variant: variant,
      );
    }
  }
}
