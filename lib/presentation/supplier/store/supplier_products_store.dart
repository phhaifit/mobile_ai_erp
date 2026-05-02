import 'dart:async';
import 'package:mobx/mobx.dart';
import '../../../domain/entity/supplier/supplier_product_link.dart';
import '../../../domain/entity/supplier/product_summary.dart';
import '../../../domain/usecase/supplier/supplier_usecases.dart';
import 'supplier_store_error_parser.dart';

part 'supplier_products_store.g.dart';
class SupplierProductsStore = SupplierProductsStoreBase with _$SupplierProductsStore;

abstract class SupplierProductsStoreBase with Store {
  final GetSupplierProductsUseCase _getSupplierProducts;
  final AddProductToSupplierUseCase _addProductToSupplier;
  final UpdateProductSupplierLinkUseCase _updateProductSupplierLink;
  final RemoveProductFromSupplierUseCase _removeProductFromSupplier;
  final SearchProductsUseCase _searchProducts;
  SupplierProductsStoreBase(this._getSupplierProducts, this._addProductToSupplier,
      this._updateProductSupplierLink, this._removeProductFromSupplier, this._searchProducts);
  @observable
  ObservableList<SupplierProductLink> supplierProducts = ObservableList();
  @observable
  int supplierProductsPage = 1, supplierProductsTotalPages = 1, supplierProductsTotalItems = 0;
  @observable
  ObservableList<ProductSummary> availableProducts = ObservableList();
  @observable
  int productSearchPage = 1, productSearchTotalPages = 1, productSearchTotalItems = 0;
  @observable
  bool hasMoreProducts = false;
  @observable
  bool isLoading = false, isSubmitting = false;
  @observable
  String? errorMessage;
  String _currentSupplierId = '', _currentSupplierProductsSearchQuery = '', _currentProductSearchQuery = '';
  int _supplierProductsRequestId = 0; Timer? _searchDebounce;

  @action
  Future<void> loadSupplierProducts(String supplierId, {int page = 1}) async {
    final requestId = ++_supplierProductsRequestId;
    _currentSupplierId = supplierId;
    isLoading = true;
    errorMessage = null;
    try {
      final result = await _getSupplierProducts(
        supplierId,
        page: page,
        search: _currentSupplierProductsSearchQuery,
      );
      if (requestId != _supplierProductsRequestId) return;
      supplierProducts = ObservableList.of(result.data);
      supplierProductsPage = result.page;
      supplierProductsTotalPages = result.totalPages;
      supplierProductsTotalItems = result.totalItems;
    } catch (e) {
      if (requestId == _supplierProductsRequestId) {
        errorMessage = parseSupplierStoreError(e);
      }
    } finally {
      if (requestId == _supplierProductsRequestId) isLoading = false;
    }
  }
  @action
  Future<void> nextSupplierProductsPage() async {
    if (supplierProductsPage < supplierProductsTotalPages) await loadSupplierProducts(_currentSupplierId, page: supplierProductsPage + 1);
  }
  @action
  Future<void> previousSupplierProductsPage() async {
    if (supplierProductsPage > 1) await loadSupplierProducts(_currentSupplierId, page: supplierProductsPage - 1);
  }
  @action
  void setSupplierProductsSearchQuery(String query) {
    _currentSupplierProductsSearchQuery = query.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => loadSupplierProducts(_currentSupplierId, page: 1),
    );
  }
  @action
  Future<bool> addProductToSupplier(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool isPrimary = false,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    try {
      await _addProductToSupplier(
        productId,
        supplierId,
        supplierSku: supplierSku,
        costPrice: costPrice,
        isPrimary: isPrimary,
      );
      await loadSupplierProducts(supplierId);
      await searchProducts(_currentProductSearchQuery, reset: false);
      isSubmitting = false;
      return true;
    } catch (e) {
      errorMessage = parseSupplierStoreError(e);
      isSubmitting = false;
      return false;
    }
  }
  @action
  Future<bool> updateProductSupplierLink(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool? isPrimary,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    try {
      await _updateProductSupplierLink(
        productId,
        supplierId,
        supplierSku: supplierSku,
        costPrice: costPrice,
        isPrimary: isPrimary,
      );
      await loadSupplierProducts(supplierId);
      isSubmitting = false;
      return true;
    } catch (e) {
      errorMessage = parseSupplierStoreError(e);
      isSubmitting = false;
      return false;
    }
  }
  @action
  Future<bool> removeProductFromSupplier(
    String productId,
    String supplierId,
  ) async {
    isSubmitting = true;
    errorMessage = null;
    try {
      await _removeProductFromSupplier(productId, supplierId);
      final targetPage = supplierProducts.length <= 1 && supplierProductsPage > 1
          ? supplierProductsPage - 1
          : supplierProductsPage;
      await loadSupplierProducts(supplierId, page: targetPage);
      isSubmitting = false;
      return true;
    } catch (e) {
      errorMessage = parseSupplierStoreError(e);
      isSubmitting = false;
      return false;
    }
  }
  @action
  Future<void> searchProducts(String query, {bool reset = true}) async {
    if (reset) {
      productSearchPage = 1;
      _currentProductSearchQuery = query;
      availableProducts.clear();
    }
    isLoading = true;
    try {
      final result = await _searchProducts(
        search: _currentProductSearchQuery,
        page: productSearchPage,
        pageSize: 10,
      );
      availableProducts = ObservableList.of(result.data);
      productSearchTotalPages = result.totalPages;
      productSearchTotalItems = result.totalItems;
      hasMoreProducts = result.hasNextPage;
    } catch (e) {
      errorMessage = parseSupplierStoreError(e);
    } finally {
      isLoading = false;
    }
  }
  @action
  Future<void> nextProductSearchPage() async { if (productSearchPage < productSearchTotalPages) {
      productSearchPage += 1; await searchProducts(_currentProductSearchQuery, reset: false); } }
  @action
  Future<void> previousProductSearchPage() async { if (productSearchPage > 1) {
      productSearchPage -= 1; await searchProducts(_currentProductSearchQuery, reset: false); } }
  @action
  void resetSupplierProductsView() {
    _supplierProductsRequestId++;
    _currentSupplierId = _currentSupplierProductsSearchQuery = '';
    supplierProducts = ObservableList();
    supplierProductsPage = 1;
    supplierProductsTotalPages = 1;
    supplierProductsTotalItems = 0;
    isLoading = false;
    errorMessage = null;
  }
  void clearError() => errorMessage = null;
  void dispose() => _searchDebounce?.cancel();
}
