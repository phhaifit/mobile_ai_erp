import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';

part 'product_listing_store.g.dart';

enum SortOption {
  relevance,
  popular,
  timeAsc,
  timeDesc,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  rating,
}

class ListingFilters = _ListingFiltersStore with _$ListingFilters;

abstract class _ListingFiltersStore with Store {
  _ListingFiltersStore(this._repository);

  final StorefrontRepository _repository;
  Timer? _searchDebounce;

  @observable
  String searchQuery = '';

  @observable
  ObservableList<String> categoryFilter = ObservableList<String>();

  @observable
  ObservableList<String> brandFilter = ObservableList<String>();

  @observable
  ObservableList<String> attributeValueFilter = ObservableList<String>();

  @observable
  SortOption? sortOption = SortOption.timeDesc;

  @observable
  ObservableList<StorefrontProduct> products = ObservableList<StorefrontProduct>();

  @observable
  ObservableList<StorefrontFacetOption> categories = ObservableList<StorefrontFacetOption>();

  @observable
  ObservableList<StorefrontFacetOption> brands = ObservableList<StorefrontFacetOption>();

  @observable
  ObservableList<StorefrontAttributeFacet> attributeFacets =
      ObservableList<StorefrontAttributeFacet>();

  @observable
  ObservableList<StorefrontCategorySummary> breadcrumb =
      ObservableList<StorefrontCategorySummary>();

  @observable
  bool isLoading = false;

  @observable
  bool isLoadingMore = false;

  @observable
  bool hasMore = true;

  @observable
  String? errorMessage;

  @observable
  int currentPage = 1;

  @observable
  String? activeCategoryKey;

  @observable
  String? activeBrandKey;

  @observable
  String? activeCollectionSlug;

  @action
  void setSearchQuery(String value) {
    searchQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => updateProducts(),
    );
  }

  @action
  void setCategoryFilter(List<String> categoryIds) {
    categoryFilter = ObservableList.of(categoryIds);
  }

  @action
  void toggleCategoryFilter(String categoryId) {
    if (categoryFilter.contains(categoryId)) {
      categoryFilter.remove(categoryId);
    } else {
      categoryFilter
        ..clear()
        ..add(categoryId);
    }
  }

  @action
  void clearCategoryFilters() {
    categoryFilter.clear();
  }

  @action
  void setBrandFilter(List<String> brandIds) {
    brandFilter = ObservableList.of(brandIds);
  }

  @action
  void toggleBrandFilter(String brandId) {
    if (brandFilter.contains(brandId)) {
      brandFilter.remove(brandId);
    } else {
      brandFilter
        ..clear()
        ..add(brandId);
    }
  }

  @action
  void clearBrandFilters() {
    brandFilter.clear();
  }

  @action
  void toggleAttributeFilter(String attributeValueId) {
    if (attributeValueFilter.contains(attributeValueId)) {
      attributeValueFilter.remove(attributeValueId);
    } else {
      attributeValueFilter.add(attributeValueId);
    }
  }

  @action
  void clearAttributeFilters() {
    attributeValueFilter.clear();
  }

  @action
  void setSortOption(SortOption? value) {
    sortOption = value;
  }

  @action
  void resetFilters() {
    searchQuery = '';
    categoryFilter.clear();
    brandFilter.clear();
    attributeValueFilter.clear();
    sortOption = SortOption.timeDesc;
    activeCategoryKey = null;
    activeBrandKey = null;
    activeCollectionSlug = null;
    breadcrumb.clear();
  }

  @action
  Future<void> applyArguments({
    String? search,
    List<String>? categories,
    List<String>? brands,
    SortOption? sort,
    String? categoryKey,
    String? brandKey,
    String? collectionSlug,
  }) async {
    if (search != null) {
      searchQuery = search;
    }
    if (categories != null) {
      setCategoryFilter(categories);
    }
    if (brands != null) {
      setBrandFilter(brands);
    }
    if (sort != null) {
      sortOption = sort;
    }
    activeCategoryKey = categoryKey;
    activeBrandKey = brandKey;
    activeCollectionSlug = collectionSlug;
    await updateProducts();
  }

  @action
  Future<void> updateProducts() async {
    isLoading = true;
    errorMessage = null;
    currentPage = 1;
    try {
      final query = _buildQuery(page: 1);
      final productResponse = await _loadProducts(query);
      final facets = await _repository.getFacets(query);
      products = ObservableList.of(productResponse.data);
      hasMore = productResponse.hasMore;
      currentPage = productResponse.page;
      categories = ObservableList.of(facets.categories);
      brands = ObservableList.of(facets.brands);
      attributeFacets = ObservableList.of(facets.attributes);

      if (activeCategoryKey != null && activeCategoryKey!.isNotEmpty) {
        final categoryDetail =
            await _repository.getCategoryDetail(activeCategoryKey!);
        breadcrumb = ObservableList.of(categoryDetail.breadcrumb);
      } else if (categoryFilter.isNotEmpty) {
        final categoryDetail =
            await _repository.getCategoryDetail(categoryFilter.first);
        breadcrumb = ObservableList.of(categoryDetail.breadcrumb);
      } else {
        breadcrumb.clear();
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) {
      return;
    }
    isLoadingMore = true;
    try {
      final nextPage = currentPage + 1;
      final response = await _loadProducts(_buildQuery(page: nextPage));
      products.addAll(response.data);
      currentPage = response.page;
      hasMore = response.hasMore;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoadingMore = false;
    }
  }

  Future<StorefrontPaginatedResponse<StorefrontProduct>> _loadProducts(
    StorefrontProductQuery query,
  ) {
    if (activeBrandKey != null && activeBrandKey!.isNotEmpty) {
      return _repository.getBrandProducts(activeBrandKey!, query);
    }
    if (activeCollectionSlug != null && activeCollectionSlug!.isNotEmpty) {
      return _repository.getCollectionProducts(activeCollectionSlug!, query);
    }
    return _repository.getProducts(query);
  }

  StorefrontProductQuery _buildQuery({required int page}) {
    return StorefrontProductQuery(
      page: page,
      pageSize: 12,
      search: searchQuery,
      sortBy: _sortValue(sortOption),
      categoryId: categoryFilter.isNotEmpty
          ? categoryFilter.first
          : activeCategoryKey,
      brandId: brandFilter.isNotEmpty ? brandFilter.first : null,
      attributeValueIds: attributeValueFilter.toList(),
      collection: activeCollectionSlug,
      includeHighlights: true,
    );
  }

  String _sortValue(SortOption? option) {
    switch (option) {
      case SortOption.priceAsc:
        return 'price_asc';
      case SortOption.priceDesc:
        return 'price_desc';
      case SortOption.rating:
        return 'rating_desc';
      case SortOption.popular:
      case SortOption.relevance:
        return 'popular';
      case SortOption.timeAsc:
        return 'newest';
      case SortOption.nameAsc:
      case SortOption.nameDesc:
      case SortOption.timeDesc:
      case null:
        return 'newest';
    }
  }
}
