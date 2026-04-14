import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/create_brand_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/delete_brand_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/get_brands_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/update_brand_usecase.dart';
import 'package:mobx/mobx.dart';

part 'brand_store.g.dart';

class BrandStore = BrandStoreBase with _$BrandStore;

abstract class BrandStoreBase with Store {
  BrandStoreBase({
    required GetBrandsUseCase getBrandsUseCase,
    required CreateBrandUseCase createBrandUseCase,
    required UpdateBrandUseCase updateBrandUseCase,
    required DeleteBrandUseCase deleteBrandUseCase,
    required this.errorStore,
  }) : _getBrandsUseCase = getBrandsUseCase,
       _createBrandUseCase = createBrandUseCase,
       _updateBrandUseCase = updateBrandUseCase,
       _deleteBrandUseCase = deleteBrandUseCase;

  final GetBrandsUseCase _getBrandsUseCase;
  final CreateBrandUseCase _createBrandUseCase;
  final UpdateBrandUseCase _updateBrandUseCase;
  final DeleteBrandUseCase _deleteBrandUseCase;

  final ErrorStore errorStore;

  @observable
  ObservableList<Brand> brands = ObservableList<Brand>();

  @observable
  int currentPage = 1;

  @observable
  int pageSize = 10;

  @observable
  int totalItems = 0;

  @observable
  int totalPages = 0;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  String? searchQuery;

  @observable
  bool includeInactive = false;

  @observable
  String? sortBy;

  @observable
  String? sortOrder;

  @action
  Future<void> loadBrands({
    int page = 1,
    int pageSize = 10,
    String? search,
    bool includeInactive = false,
    String? sortBy,
    String? sortOrder,
  }) async {
    await _runWithLoading(() async {
      try {
        final result = await _getBrandsUseCase.call(
          params: GetBrandsParams(
            page: page,
            pageSize: pageSize,
            search: search,
            includeInactive: includeInactive,
            sortBy: sortBy,
            sortOrder: sortOrder,
          ),
        );
        _applyMetadataPage(result);
        searchQuery = search;
        this.includeInactive = includeInactive;
        this.sortBy = sortBy;
        this.sortOrder = sortOrder;
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<Brand> createBrand(Brand brand) async {
    return await _runWithLoading(() async {
      try {
        final result = await _createBrandUseCase.call(params: brand);
        await _reloadCurrentQuery();
        error = null;
        return result;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<Brand> updateBrand(Brand brand) async {
    return await _runWithLoading(() async {
      try {
        final result = await _updateBrandUseCase.call(params: brand);
        await _reloadCurrentQuery();
        error = null;
        return result;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<void> deleteBrand(String brandId) async {
    await _runWithLoading(() async {
      try {
        await _deleteBrandUseCase.call(params: brandId);
        await _reloadCurrentQuery();
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  int _loadingOperations = 0;

  @action
  void _beginLoadingOperation() {
    _loadingOperations++;
    isLoading = _loadingOperations > 0;
  }

  @action
  void _endLoadingOperation() {
    if (_loadingOperations > 0) {
      _loadingOperations--;
    }
    isLoading = _loadingOperations > 0;
  }

  Future<T> _runWithLoading<T>(Future<T> Function() fn) async {
    _beginLoadingOperation();
    try {
      return await fn();
    } finally {
      _endLoadingOperation();
    }
  }

  Future<void> _reloadCurrentQuery() async {
    await _runWithLoading(() async {
      final result = await _getBrandsUseCase.call(
        params: GetBrandsParams(
          page: currentPage,
          pageSize: pageSize,
          search: searchQuery,
          includeInactive: includeInactive,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ),
      );
      _applyMetadataPage(result);
    });
  }

  @action
  void _applyMetadataPage(MetadataPage<Brand> page) {
    brands = ObservableList.of(page.items);
    currentPage = page.page;
    pageSize = page.pageSize;
    totalItems = page.totalItems;
    totalPages = page.totalPages;
  }
}
