import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/create_category_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/delete_category_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/get_categories_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/update_category_usecase.dart';
import 'package:mobx/mobx.dart';

part 'category_store.g.dart';

class CategoryStore = CategoryStoreBase with _$CategoryStore;

abstract class CategoryStoreBase with Store {
  CategoryStoreBase({required GetCategoriesUseCase getCategoriesUseCase, required CreateCategoryUseCase createCategoryUseCase, required UpdateCategoryUseCase updateCategoryUseCase, required DeleteCategoryUseCase deleteCategoryUseCase, required this.errorStore})
      : _getCategoriesUseCase = getCategoriesUseCase,
        _createCategoryUseCase = createCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase;

  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  final ErrorStore errorStore;

  @observable ObservableList<Category> categories = ObservableList<Category>();

  final ObservableList<Category> parentOptions = ObservableList<Category>();

  @observable int currentPage = 1;

  @observable int pageSize = 10;

  @observable int totalItems = 0;

  @observable int totalPages = 0;

  @observable int unfilteredTotal = 0;

  @observable bool isLoading = false;

  @observable String? error;

  @observable String? searchQuery;

  @observable String? sortBy;

  @observable String? sortOrder;

  @observable CategoryStatus? statusFilter;

  @action
  Future<void> loadCategories({int page = 1, int pageSize = 10, String? search, String? sortBy, String? sortOrder, CategoryStatus? status, String? parentId, bool rootOnly = false}) async {
    await _runWithLoading(() async {
      try {
        final result = await _getCategoriesUseCase.call(
          params: GetCategoriesParams(
            page: page,
            pageSize: pageSize,
            search: search,
            sortBy: sortBy,
            sortOrder: sortOrder,
            status: status,
            parentId: parentId,
            rootOnly: rootOnly,
          ),
        );
        _applyMetadataPage(result);
        if (search == null && status == null) unfilteredTotal = result.totalItems;
        searchQuery = search;
        this.sortBy = sortBy;
        this.sortOrder = sortOrder;
        statusFilter = status;
        error = null;
      } catch (e) {
        _handleError(e);
        rethrow;
      }
    });
  }

  Future<void> loadParentOptions() async {
    final result = await _getCategoriesUseCase.call(
      params: GetCategoriesParams(pageSize: 200, rootOnly: false),
    );
    parentOptions
      ..clear()
      ..addAll(result.items);
  }

  Future<MetadataPage<Category>> fetchCategoriesPage({int page = 1, int pageSize = 10, String? search, String? sortBy, String? sortOrder, CategoryStatus? status, String? parentId, bool rootOnly = false}) =>
      _getCategoriesUseCase.call(
        params: GetCategoriesParams(
          page: page,
          pageSize: pageSize,
          search: search,
          sortBy: sortBy,
          sortOrder: sortOrder,
          status: status,
          parentId: parentId,
          rootOnly: rootOnly,
        ),
      );

  @action
  Future<Category> createCategory(Category category) async {
    return await _runWithLoading(() async {
      try {
        final result = await _createCategoryUseCase.call(params: category);
        error = null;
        return result;
      } catch (e) {
        _handleError(e);
        rethrow;
      }
    });
  }

  @action
  Future<Category> updateCategory(Category category) async {
    return await _runWithLoading(() async {
      try {
        final result = await _updateCategoryUseCase.call(params: category);
        error = null;
        return result;
      } catch (e) {
        _handleError(e);
        rethrow;
      }
    });
  }

  @action
  Future<void> deleteCategory(String categoryId) async {
    await _runWithLoading(() async {
      try {
        await _deleteCategoryUseCase.call(params: categoryId);
        error = null;
      } catch (e) {
        _handleError(e);
        rethrow;
      }
    });
  }

  int _loadingOperations = 0;

  @action
  void _beginLoadingOperation() { _loadingOperations++; isLoading = true; }

  @action
  void _endLoadingOperation() {
    if (_loadingOperations > 0) _loadingOperations--;
    isLoading = _loadingOperations > 0;
  }

  void _handleError(Object e) {
    error = e.toString();
    errorStore.setErrorMessage(e.toString());
  }

  Future<T> _runWithLoading<T>(Future<T> Function() fn) async {
    _beginLoadingOperation();
    try {
      return await fn();
    } finally {
      _endLoadingOperation();
    }
  }

  @action
  void _applyMetadataPage(MetadataPage<Category> page) {
    categories = ObservableList.of(page.items);
    currentPage = page.page;
    pageSize = page.pageSize;
    totalItems = page.totalItems;
    totalPages = page.totalPages;
  }
}
