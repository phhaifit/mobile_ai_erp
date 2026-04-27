import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_set_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/get_brand_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/get_tag_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/get_category_by_id_usecase.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/attribute_set_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/brand_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/category_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/tag_store.dart';
import 'package:mobx/mobx.dart';

part 'product_metadata_store.g.dart';

class ProductMetadataStore = ProductMetadataStoreBase with _$ProductMetadataStore;

abstract class ProductMetadataStoreBase with Store {
  ProductMetadataStoreBase({
    required CategoryStore categoryStore,
    required BrandStore brandStore,
    required TagStore tagStore,
    required AttributeSetStore attributeSetStore,
    required GetBrandByIdUseCase getBrandByIdUseCase,
    required GetTagByIdUseCase getTagByIdUseCase,
    required GetCategoryByIdUseCase getCategoryByIdUseCase,
    required GetAttributeSetByIdUseCase getAttributeSetByIdUseCase,
    required this.errorStore,
  }) : _categoryStore = categoryStore,
       _brandStore = brandStore,
       _tagStore = tagStore,
       _attributeSetStore = attributeSetStore,
       _getBrandByIdUseCase = getBrandByIdUseCase,
       _getTagByIdUseCase = getTagByIdUseCase,
       _getCategoryByIdUseCase = getCategoryByIdUseCase,
       _getAttributeSetByIdUseCase = getAttributeSetByIdUseCase;

  final CategoryStore _categoryStore;
  final BrandStore _brandStore;
  final TagStore _tagStore;
  final AttributeSetStore _attributeSetStore;
  final GetBrandByIdUseCase _getBrandByIdUseCase;
  final GetTagByIdUseCase _getTagByIdUseCase;
  final GetCategoryByIdUseCase _getCategoryByIdUseCase;
  final GetAttributeSetByIdUseCase _getAttributeSetByIdUseCase;
  final ErrorStore errorStore;

  @observable
  bool hasLoadedDashboard = false;

  ObservableList<Category> get categories => _categoryStore.categories;
  ObservableList<Category> get categoryTree => _categoryStore.categoryTree;
  int get categoryCurrentPage => _categoryStore.currentPage;
  int get categoryPageSize => _categoryStore.pageSize;
  int get categoryTotalItems => _categoryStore.totalItems;
  int get categoryUnfilteredTotal => _categoryStore.unfilteredTotal;
  int get categoryTotalPages => _categoryStore.totalPages;
  bool get isCategoryLoading => _categoryStore.isLoading;
  Future<void> loadCategories({int page = 1, int pageSize = 10, String? search, String? sortBy, String? sortOrder, CategoryStatus? status}) =>
      _categoryStore.loadCategories(page: page, pageSize: pageSize, search: search, sortBy: sortBy, sortOrder: sortOrder, status: status);
  Future<void> loadCategoryTree({CategoryStatus? status}) =>
      _categoryStore.loadCategoryTree(status: status);
  Future<Category> createCategory(Category category) =>
      _categoryStore.createCategory(category);
  Future<Category> updateCategory(Category category) =>
      _categoryStore.updateCategory(category);
  Future<void> deleteCategory(String categoryId) =>
      _categoryStore.deleteCategory(categoryId);
  Future<Category> getCategoryById(String categoryId) =>
      _getCategoryByIdUseCase.call(params: categoryId);

  ObservableList<Brand> get brands => _brandStore.brands;
  int get brandCurrentPage => _brandStore.currentPage;
  int get brandPageSize => _brandStore.pageSize;
  int get brandTotalItems => _brandStore.totalItems;
  int get brandUnfilteredTotal => _brandStore.unfilteredTotal;
  int get brandTotalPages => _brandStore.totalPages;
  bool get isBrandLoading => _brandStore.isLoading;
  Future<void> loadBrands({int page = 1, int pageSize = 10, String? search, String? sortBy, String? sortOrder}) =>
      _brandStore.loadBrands(page: page, pageSize: pageSize, search: search, sortBy: sortBy, sortOrder: sortOrder);
  Future<Brand> createBrand(Brand brand) => _brandStore.createBrand(brand);
  Future<Brand> updateBrand(Brand brand) => _brandStore.updateBrand(brand);
  Future<void> deleteBrand(String brandId) => _brandStore.deleteBrand(brandId);
  Future<Brand> getBrandById(String brandId) =>
      _getBrandByIdUseCase.call(params: brandId);

  ObservableList<Tag> get tags => _tagStore.tags;
  int get tagCurrentPage => _tagStore.currentPage;
  int get tagPageSize => _tagStore.pageSize;
  int get tagTotalItems => _tagStore.totalItems;
  int get tagUnfilteredTotal => _tagStore.unfilteredTotal;
  int get tagTotalPages => _tagStore.totalPages;
  bool get isTagLoading => _tagStore.isLoading;
  Future<void> loadTags({int page = 1, int pageSize = 10, String? search, String? sortBy, String? sortOrder}) =>
      _tagStore.loadTags(page: page, pageSize: pageSize, search: search, sortBy: sortBy, sortOrder: sortOrder);
  Future<Tag> createTag(Tag tag) => _tagStore.createTag(tag);
  Future<Tag> updateTag(Tag tag) => _tagStore.updateTag(tag);
  Future<void> deleteTag(String tagId) => _tagStore.deleteTag(tagId);
  Future<Tag> getTagById(String tagId) =>
      _getTagByIdUseCase.call(params: tagId);

  ObservableList<AttributeSet> get attributeSets =>
      _attributeSetStore.attributeSets;
  int get attributeSetCurrentPage => _attributeSetStore.currentPage;
  int get attributeSetPageSize => _attributeSetStore.pageSize;
  int get attributeSetTotalItems => _attributeSetStore.totalItems;
  int get attributeSetUnfilteredTotal => _attributeSetStore.unfilteredTotal;
  int get attributeSetTotalPages => _attributeSetStore.totalPages;
  bool get isAttributeSetLoading => _attributeSetStore.isLoading;
  ObservableList<AttributeValue> get allAttributeValues =>
      _attributeSetStore.allAttributeValues;
  Future<void> loadAllAttributeValues() =>
      _attributeSetStore.loadAllAttributeValues();
  Future<void> loadAttributeSets({int page = 1, int pageSize = 10, String? search, String? sortBy, String? sortOrder}) =>
      _attributeSetStore.loadAttributeSets(page: page, pageSize: pageSize, search: search, sortBy: sortBy, sortOrder: sortOrder);
  Future<AttributeSet> createAttributeSet(AttributeSet attributeSet) =>
      _attributeSetStore.createAttributeSet(attributeSet);
  Future<AttributeSet> updateAttributeSet(AttributeSet attributeSet) =>
      _attributeSetStore.updateAttributeSet(attributeSet);
  Future<void> deleteAttributeSet(String attributeSetId) =>
      _attributeSetStore.deleteAttributeSet(attributeSetId);
  Future<AttributeSet> getAttributeSetById(String attributeSetId) =>
      _getAttributeSetByIdUseCase.call(params: attributeSetId);

  ObservableList<AttributeValue> get attributeValues =>
      _attributeSetStore.attributeValues;
  Future<void> loadAttributeValues(String attributeSetId) =>
      _attributeSetStore.loadAttributeValues(attributeSetId);
  Future<AttributeValue> createAttributeValue(AttributeValue value) =>
      _attributeSetStore.createAttributeValue(value);
  Future<AttributeValue> updateAttributeValue(AttributeValue value) =>
      _attributeSetStore.updateAttributeValue(value);
  Future<void> deleteAttributeValue(String attributeSetId, String valueId) =>
      _attributeSetStore.deleteAttributeValue(attributeSetId, valueId);

  @computed
  bool get isLoading =>
      _categoryStore.isLoading ||
      _brandStore.isLoading ||
      _tagStore.isLoading ||
      _attributeSetStore.isLoading;

  @computed
  String? get error =>
      _categoryStore.error ??
      _brandStore.error ??
      _tagStore.error ??
      _attributeSetStore.error;

  @action
  Future<void> loadDashboard({bool force = false}) async {
    if (hasLoadedDashboard && !force) {
      return;
    }

    try {
      await Future.wait([
        loadCategories(),
        loadCategoryTree(),
        loadTags(),
        loadAttributeSets(),
        loadBrands(),
      ]);
      hasLoadedDashboard = true;
    } catch (e) {
      hasLoadedDashboard = false;
      rethrow;
    }
  }
}
