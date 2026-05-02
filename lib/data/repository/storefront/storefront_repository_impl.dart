import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_api.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';

class StorefrontRepositoryImpl implements StorefrontRepository {
  StorefrontRepositoryImpl(this._api);

  final StorefrontApi _api;

  @override
  Future<StorefrontHomeData> getHome() => _api.getHome();

  @override
  Future<StorefrontPaginatedResponse<StorefrontProduct>> getProducts(
    StorefrontProductQuery query,
  ) =>
      _api.getProducts(query);

  @override
  Future<StorefrontFacets> getFacets(StorefrontProductQuery query) =>
      _api.getFacets(query);

  @override
  Future<StorefrontProductDetail> getProductDetail(String productId) =>
      _api.getProductDetail(productId);

  @override
  Future<List<StorefrontCategoryTreeNode>> getCategories() =>
      _api.getCategories();

  @override
  Future<StorefrontCategoryDetail> getCategoryDetail(String categoryKey) =>
      _api.getCategoryDetail(categoryKey);

  @override
  Future<List<StorefrontBrand>> getBrands() => _api.getBrands();

  @override
  Future<StorefrontPaginatedResponse<StorefrontProduct>> getBrandProducts(
    String brandKey,
    StorefrontProductQuery query,
  ) =>
      _api.getBrandProducts(brandKey, query);

  @override
  Future<List<StorefrontCollection>> getCollections() =>
      _api.getCollections();

  @override
  Future<StorefrontPaginatedResponse<StorefrontProduct>> getCollectionProducts(
    String collectionSlug,
    StorefrontProductQuery query,
  ) =>
      _api.getCollectionProducts(collectionSlug, query);
}
