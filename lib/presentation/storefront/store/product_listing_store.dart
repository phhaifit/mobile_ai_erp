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
  double? minPriceFilter;

  @observable
  double? maxPriceFilter;

  @observable
  double? ratingFilter;

  @observable
  String? availabilityFilter;

  @observable
  ObservableList<StorefrontProduct> products =
      ObservableList<StorefrontProduct>();

  @observable
  ObservableList<StorefrontFacetOption> categories =
      ObservableList<StorefrontFacetOption>();

  @observable
  ObservableList<StorefrontFacetOption> brands =
      ObservableList<StorefrontFacetOption>();

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

  @observable
  double availableMinPrice = 0;

  @observable
  double availableMaxPrice = 0;

  @observable
  int inStockCount = 0;

  @observable
  int outOfStockCount = 0;

  @observable
  ObservableList<int> availableRatings = ObservableList<int>();

  @computed
  bool get hasAnyFilters =>
      categoryFilter.isNotEmpty ||
      brandFilter.isNotEmpty ||
      attributeValueFilter.isNotEmpty ||
      minPriceFilter != null ||
      maxPriceFilter != null ||
      ratingFilter != null ||
      availabilityFilter != null;

  @computed
  bool get hasSearchText => searchQuery.trim().isNotEmpty;

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
      if (activeCategoryKey == categoryId) {
        activeCategoryKey = null;
      }
    } else {
      categoryFilter
        ..clear()
        ..add(categoryId);
      activeCategoryKey = null;
    }
  }

  @action
  void clearCategoryFilters() {
    categoryFilter.clear();
    activeCategoryKey = null;
  }

  @action
  void setBrandFilter(List<String> brandIds) {
    brandFilter = ObservableList.of(brandIds);
  }

  @action
  void toggleBrandFilter(String brandId) {
    if (brandFilter.contains(brandId)) {
      brandFilter.remove(brandId);
      if (activeBrandKey == brandId) {
        activeBrandKey = null;
      }
    } else {
      brandFilter
        ..clear()
        ..add(brandId);
      activeBrandKey = null;
    }
  }

  @action
  void clearBrandFilters() {
    brandFilter.clear();
    activeBrandKey = null;
  }

  @action
  void setAttributeFilters(List<String> attributeValueIds) {
    attributeValueFilter = ObservableList.of(attributeValueIds);
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
  void setPriceRange({double? min, double? max}) {
    minPriceFilter = min;
    maxPriceFilter = max;
  }

  @action
  void setRatingFilter(double? value) {
    ratingFilter = value;
  }

  @action
  void setAvailabilityFilter(String? value) {
    availabilityFilter = value;
  }

  @action
  void clearAdvancedFilters() {
    minPriceFilter = null;
    maxPriceFilter = null;
    ratingFilter = null;
    availabilityFilter = null;
    attributeValueFilter.clear();
  }

  @action
  void resetFilters() {
    _searchDebounce?.cancel();
    searchQuery = '';
    categoryFilter.clear();
    brandFilter.clear();
    attributeValueFilter.clear();
    sortOption = SortOption.timeDesc;
    minPriceFilter = null;
    maxPriceFilter = null;
    ratingFilter = null;
    availabilityFilter = null;
    activeCategoryKey = null;
    activeBrandKey = null;
    activeCollectionSlug = null;
    breadcrumb.clear();
    errorMessage = null;
  }

  @action
  Future<void> applyArguments({
    String? search,
    List<String>? categories,
    List<String>? brands,
    List<String>? attributeValueIds,
    SortOption? sort,
    String? categoryKey,
    String? brandKey,
    String? collectionSlug,
    double? minPrice,
    double? maxPrice,
    double? rating,
    String? availability,
  }) async {
    resetFilters();
    if (search != null) {
      searchQuery = search;
    }
    if (categories != null) {
      setCategoryFilter(categories);
    }
    if (brands != null) {
      setBrandFilter(brands);
    }
    if (attributeValueIds != null) {
      setAttributeFilters(attributeValueIds);
    }
    if (sort != null) {
      sortOption = sort;
    }
    minPriceFilter = minPrice;
    maxPriceFilter = maxPrice;
    ratingFilter = rating;
    availabilityFilter = availability;
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
      products = ObservableList.of(productResponse.data);
      hasMore = productResponse.hasMore;
      currentPage = productResponse.page;
      await _loadDiscoveryMetadata(query);
    } catch (error) {
      products.clear();
      hasMore = false;
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

  Future<void> _loadDiscoveryMetadata(StorefrontProductQuery query) async {
    try {
      final facets = await _repository.getFacets(query);
      categories = ObservableList.of(facets.categories);
      brands = ObservableList.of(facets.brands);
      attributeFacets = ObservableList.of(facets.attributes);
      availableMinPrice = facets.minPrice;
      availableMaxPrice = facets.maxPrice;
      inStockCount = facets.inStockCount;
      outOfStockCount = facets.outOfStockCount;
      availableRatings = ObservableList.of(facets.ratings);
    } catch (_) {
      categories.clear();
      brands.clear();
      attributeFacets.clear();
      availableMinPrice = 0;
      availableMaxPrice = 0;
      inStockCount = 0;
      outOfStockCount = 0;
      availableRatings.clear();
    }

    try {
      if (activeCategoryKey != null && activeCategoryKey!.isNotEmpty) {
        final categoryDetail = await _repository.getCategoryDetail(
          activeCategoryKey!,
        );
        breadcrumb = ObservableList.of(categoryDetail.breadcrumb);
        return;
      }
      if (categoryFilter.isNotEmpty) {
        final selectedCategoryId = categoryFilter.first;
        final matchedCategory = categories.firstWhere(
          (category) => category.id == selectedCategoryId,
          orElse: () => StorefrontFacetOption(
            id: selectedCategoryId,
            name: selectedCategoryId,
            count: 0,
          ),
        );
        breadcrumb = ObservableList.of([
          StorefrontCategorySummary(
            id: matchedCategory.id,
            name: matchedCategory.name,
            slug: matchedCategory.slug ?? matchedCategory.id,
          ),
        ]);
        return;
      }
      breadcrumb.clear();
    } catch (_) {
      breadcrumb.clear();
    }
  }

  StorefrontProductQuery _buildQuery({required int page}) {
    return StorefrontProductQuery(
      page: page,
      pageSize: 12,
      search: searchQuery,
      sortBy: _sortValue(sortOption),
      categoryId: categoryFilter.isNotEmpty ? categoryFilter.first : null,
      brandId: brandFilter.isNotEmpty ? brandFilter.first : null,
      minPrice: minPriceFilter,
      maxPrice: maxPriceFilter,
      rating: ratingFilter,
      availability: availabilityFilter,
      attributeValueIds: attributeValueFilter.toList(),
      collection: activeCollectionSlug,
      includeHighlights: true,
    );
  }

  String? _sortValue(SortOption? option) {
    switch (option) {
      case SortOption.relevance:
        return searchQuery.trim().isNotEmpty ? 'relevance' : 'popular';
      case SortOption.popular:
        return 'popular';
      case SortOption.timeAsc:
        return 'oldest';
      case SortOption.timeDesc:
        return 'newest';
      case SortOption.nameAsc:
        return 'name_asc';
      case SortOption.nameDesc:
        return 'name_desc';
      case SortOption.priceAsc:
        return 'price_asc';
      case SortOption.priceDesc:
        return 'price_desc';
      case SortOption.rating:
        return 'rating_desc';
      case null:
        return searchQuery.trim().isNotEmpty ? 'relevance' : 'newest';
    }
  }
}
