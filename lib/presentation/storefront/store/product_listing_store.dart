import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
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
  static final DateTime _mockTimestamp = DateTime(2026, 4, 10);

  static Brand _brand(String id, String name) {
    return Brand(
      id: id,
      tenantId: 'tenant_demo',
      name: name,
      createdAt: _mockTimestamp,
      updatedAt: _mockTimestamp,
    );
  }

  static Category _category({
    required String id,
    required String name,
    required String slug,
    String? parentId,
  }) {
    return Category(
      id: id,
      tenantId: 'tenant_demo',
      name: name,
      slug: slug,
      parentId: parentId,
      createdAt: _mockTimestamp,
      updatedAt: _mockTimestamp,
    );
  }

  // test data
  final List<Product> testProducts = [
          Product(
        id: 1,
        name: 'Smile',
        sku: 'SMILE-001',
        price: 2000.0,
        currency: 'USD',
        rating: 5.0,
        description: 'Premium smile product for happy customers',
        status: ProductStatus.ACTIVE,
        categoryId: 1,
        brandId: 1,
        tagIds: [1],
        imageUrls: ['https://picsum.photos/id/17/250/250'],
        category: _category(id: 'CAT1', name: 'Happy', slug: 'happy'),
        brand: _brand('BRAND1', 'CLX'),
      ),
      Product(
        id: 2,
        name: 'Surprise',
        sku: 'SURPRISE-001',
        price: 29.99,
        currency: 'USD',
        rating: 4.0,
        description: 'Amazing surprise product that delights customers',
        status: ProductStatus.ACTIVE,
        categoryId: 1,
        brandId: 2,
        tagIds: [1, 2],
        imageUrls: [],
        category: _category(id: 'CAT1', name: 'Happy', slug: 'happy'),
        brand: _brand('BRAND2', 'MGMG'),
      ),
      Product(
        id: 3,
        name: 'Fresh Pro',
        sku: 'FRESH-PRO-001',
        price: 29.99,
        currency: 'USD',
        rating: 1.0,
        description: 'Professional fresh product for everyday use',
        status: ProductStatus.ACTIVE,
        categoryId: 2,
        brandId: 2,
        tagIds: [2, 3],
        imageUrls: ['https://picsum.photos/id/19/250/250'],
        category: _category(id: 'CAT2', name: 'General', slug: 'general'),
        brand: _brand('BRAND2', 'MGMG'),
      ),
      Product(
        id: 4,
        name: 'Super Item',
        sku: 'SUPER-ITEM-001',
        price: 40.50,
        currency: 'USD',
        rating: 4.0,
        description: 'Super quality item for superior performance',
        status: ProductStatus.ACTIVE,
        categoryId: 2,
        brandId: 3,
        tagIds: [3],
        imageUrls: ['https://picsum.photos/id/20/250/250'],
        category: _category(id: 'CAT2', name: 'General', slug: 'general'),
        brand: _brand('BRAND3', 'SOUPS'),
      ),
  ].toList();


  final List<Brand> testBrands = [
    _brand('BRAND1', 'TechCorp'),
    _brand('BRAND2', 'CompuTech'),
    _brand('BRAND3', 'FashionBrand'),
  ];

  final List<Category> testCategories = [
    _category(id: 'CAT1', name: 'Electronics', slug: 'electronics'),
    _category(id: 'CAT2', name: 'Clothing', slug: 'clothing'),
    _category(id: 'CAT3', name: 'Home & Garden', slug: 'home-garden'),
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
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) 
          || product.description.toLowerCase().contains(searchQuery.toLowerCase()) 
          || (product.category != null && product.category!.name.toLowerCase().contains(searchQuery.toLowerCase())) 
          || (product.brand != null && product.brand!.name.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory =
          categoryFilter.isEmpty || (product.category != null && categoryFilter.contains(product.category!.id));
      final matchesBrand =
          brandFilter.isEmpty || (product.brand != null && brandFilter.contains(product.brand!.id));
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
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        sortedProducts.sort((a, b) => b.name.compareTo(a.name));
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
