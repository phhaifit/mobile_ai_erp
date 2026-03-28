import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

part 'product_listing_store.g.dart';

// Define SortOption enum if not already available in domain
enum SortOption {
  relevance, // sort based on relevance for user
  popular, // most popular products first
  timeAsc, // oldest first
  timeDesc, // newest first
  nameAsc, // a-z
  nameDesc, // z-a
  priceAsc, // lowest price first
  priceDesc, // highest price first
  rating, // highest rating first
}

class ListingFilters = _ListingFiltersStore with _$ListingFilters;

abstract class _ListingFiltersStore with Store {
  // test data
  final List<Product> testProducts = [
    Product(
      id: 'PT1',
      productName: 'Product A',
      category: Category(id: 'CAT1', name: 'Category 1', code: 'CAT1', slug: 'category-1'),
      brand: Brand(id: 'BRAND1', name: 'Brand A', code: 'BRAND1'),
      rating: 4.5,
      price: 19.99,
      currency: 'USD',
      imageSource: 'https://picsum.photos/250?image=2',
    ),
    Product(
      id: 'PT2',
      productName: 'Product B',
      category: Category(id: 'CAT2', name: 'Category 2', code: 'CAT2', slug: 'category-2'),
      brand: Brand(id: 'BRAND2', name: 'Brand B', code: 'BRAND2'),
      rating: 4.0,
      price: 29.99,
      currency: 'USD',
      imageSource: null,
    ),
  ];

  final List<Brand> testBrands = [
    Brand(id: 'BRAND1', name: 'Brand A', code: 'BRAND1'),
    Brand(id: 'BRAND2', name: 'Brand B', code: 'BRAND2'),
  ];

  final List<Category> testCategories = [
    Category(id: 'CAT1', name: 'Category 1', code: 'CAT1', slug: 'category-1'),
    Category(id: 'CAT2', name: 'Category 2', code: 'CAT2', slug: 'category-2'),
  ];

  // store variables
  @observable
  String searchQuery = '';

  @observable
  ObservableList<String> categoryFilter = ObservableList<String>();

  @observable
  ObservableList<String> brandFilter = ObservableList<String>();

  @observable
  SortOption? sortOption = SortOption.timeDesc;

  @observable
  ObservableList<Product> products = ObservableList<Product>();

  // actions
  @action
  void setSearchQuery(String value) {
    searchQuery = value;
  }

  @action setCategoryFilter(List<String> categoryIds) {
    categoryFilter = ObservableList.of(categoryIds);
  }

  @action
  void addCategoryFilter(String categoryId) {
    if (!categoryFilter.contains(categoryId)) {
      categoryFilter.add(categoryId);
    }
  }

  @action
  void removeCategoryFilter(String categoryId) {
    categoryFilter.remove(categoryId);
  }

  @action
  void toggleCategoryFilter(String categoryId) {
    if (categoryFilter.contains(categoryId)) {
      categoryFilter.remove(categoryId);
    } else {
      categoryFilter.add(categoryId);
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
  void addBrandFilter(String brandId) {
    if (!brandFilter.contains(brandId)) {
      brandFilter.add(brandId);
    }
  }

  @action
  void removeBrandFilter(String brandId) {
    brandFilter.remove(brandId);
  }

  @action
  void toggleBrandFilter(String brandId) {
    if (brandFilter.contains(brandId)) {
      brandFilter.remove(brandId);
    } else {
      brandFilter.add(brandId);
    }
  }

  @action
  void clearBrandFilters() {
    brandFilter.clear();
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
    sortOption = SortOption.timeDesc;
  }

  // product fetching and filtering logic
  List<Product> _filteredProductsTest(
    String searchQuery,
    List<String> categoryFilter,
    List<String> brandFilter,
  ) {
    return testProducts.where((product) {
      final matchesSearch =
          product.productName.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          categoryFilter.isEmpty || categoryFilter.contains(product.category.id);
      final matchesBrand =
          brandFilter.isEmpty || brandFilter.contains(product.brand.id);
      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();
  }

  List<Product> _fetchProducts(
    String searchQuery,
    List<String> categoryFilter,
    List<String> brandFilter,
  ) {
    return _filteredProductsTest(searchQuery, categoryFilter, brandFilter);
  }

  List<Product> _sortProducts(List<Product> productsToSort, SortOption? sortOpt) {
    List<Product> sortedProducts = List.from(productsToSort);
    switch (sortOpt) {
      case SortOption.timeAsc:
        // sort by time ascending, if product has a createdAt field
        break;
      case SortOption.timeDesc:
        // sort by time descending, if product has a createdAt field
        break;
      case SortOption.nameAsc:
        sortedProducts.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case SortOption.nameDesc:
        sortedProducts.sort((a, b) => b.productName.compareTo(a.productName));
        break;
      case SortOption.priceAsc:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }
    return sortedProducts;
  }

  @action
  void updateProducts() {
    final fetchedProducts = _fetchProducts(
      searchQuery,
      categoryFilter.toList(),
      brandFilter.toList(),
    );
    final sortedProducts = _sortProducts(fetchedProducts, sortOption);
    products = ObservableList.of(sortedProducts);
  }
}
