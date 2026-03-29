import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_filter.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';
import 'package:mobx/mobx.dart';

part 'product_store.g.dart';

class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  final String TAG = "_ProductStore";

  // repository instance
  final ProductManagementRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  static ObservableFuture<List<Product>?> emptyProductResponse =
      ObservableFuture<List<Product>?>.value(null);

  @observable
  ObservableFuture<List<Product>?> fetchProductsFuture = emptyProductResponse;

  @observable
  List<Product> productsList = [];

  @observable
  List<Product> filteredProductsList = [];

  @observable
  Product? selectedProduct;

  @observable
  bool success = false;

  @observable
  ProductFilter? currentFilter;

  // getters:-------------------------------------------------------------------
  @computed
  bool get loading => fetchProductsFuture.status == FutureStatus.pending;

  List<Product> get displayList => filteredProductsList.isEmpty && currentFilter == null
      ? productsList
      : filteredProductsList;

  // constructor:---------------------------------------------------------------
  _ProductStore(this._repository, this.errorStore) {
    fetchProducts();
  }

  // actions:-------------------------------------------------------------------
  @action
  Future<void> fetchProducts() async {
    final future = _repository.getProducts();
    fetchProductsFuture = ObservableFuture(future);

    future.then((products) {
      productsList = products;
      filteredProductsList = [];
      success = true;
    }).catchError((error) {
      errorStore.errorMessage = error.toString();
      success = false;
    });
  }

  @action
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      filteredProductsList = [];
      currentFilter = null;
      return;
    }

    final filter = ProductFilter(searchQuery: query);
    currentFilter = filter;

    try {
      final results = await _repository.searchProducts(filter);
      filteredProductsList = results;
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }

  @action
  Future<void> filterProducts(ProductFilter filter) async {
    currentFilter = filter;

    try {
      final results = await _repository.searchProducts(filter);
      filteredProductsList = results;
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }

  @action
  void clearFilter() {
    filteredProductsList = [];
    currentFilter = null;
  }

  @action
  Future<void> setSelectedProduct(Product product) async {
    selectedProduct = product;
  }

  @action
  Future<void> createProduct(Product product) async {
    try {
      final id = await _repository.createProduct(product);
      if (id > 0) {
        success = true;
        await fetchProducts();
      }
    } catch (error) {
      errorStore.errorMessage = error.toString();
      success = false;
    }
  }

  @action
  Future<void> updateProduct(Product product) async {
    try {
      final result = await _repository.updateProduct(product);
      if (result > 0) {
        success = true;
        await fetchProducts();
        selectedProduct = product;
      }
    } catch (error) {
      errorStore.errorMessage = error.toString();
      success = false;
    }
  }

  @action
  Future<void> deleteProduct(int id) async {
    try {
      final result = await _repository.deleteProduct(id);
      if (result > 0) {
        success = true;
        await fetchProducts();
        selectedProduct = null;
      }
    } catch (error) {
      errorStore.errorMessage = error.toString();
      success = false;
    }
  }

  // dispose:-------------------------------------------------------------------
  void dispose() {}
}
