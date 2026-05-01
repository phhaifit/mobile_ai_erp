import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';

abstract class StorefrontRepository {
  Future<StorefrontHomeData> getHome();

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getProducts(
    StorefrontProductQuery query,
  );

  Future<StorefrontFacets> getFacets(StorefrontProductQuery query);

  Future<StorefrontProductDetail> getProductDetail(String productId);

  Future<List<StorefrontCategoryTreeNode>> getCategories();

  Future<StorefrontCategoryDetail> getCategoryDetail(String categoryKey);

  Future<List<StorefrontBrand>> getBrands();

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getBrandProducts(
    String brandKey,
    StorefrontProductQuery query,
  );

  Future<List<StorefrontCollection>> getCollections();

  Future<StorefrontPaginatedResponse<StorefrontProduct>> getCollectionProducts(
    String collectionSlug,
    StorefrontProductQuery query,
  );
}
