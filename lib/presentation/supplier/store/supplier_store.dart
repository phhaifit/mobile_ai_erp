import 'dart:async';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import '../../../domain/entity/supplier/supplier.dart';
import '../../../domain/entity/supplier/supplier_upsert_payload.dart';
import '../../../domain/usecase/supplier/supplier_usecases.dart';

part 'supplier_store.g.dart';

class SupplierStore = SupplierStoreBase with _$SupplierStore;

abstract class SupplierStoreBase with Store {
  final GetSuppliersUseCase _getSuppliers;
  final GetSupplierByIdUseCase _getSupplierById;
  final CreateSupplierUseCase _createSupplier;
  final UpdateSupplierUseCase _updateSupplier;
  final DeleteSupplierUseCase _deleteSupplier;

  SupplierStoreBase(
    this._getSuppliers,
    this._getSupplierById,
    this._createSupplier,
    this._updateSupplier,
    this._deleteSupplier,
  );

  // ── Supplier list ──────────────────────────────────────────────────────────

  @observable
  ObservableList<Supplier> suppliers = ObservableList();

  @observable
  int currentPage = 1;

  @observable
  int pageSize = 10;

  @observable
  int totalItems = 0;

  @observable
  int totalPages = 0;

  // ── Filters ────────────────────────────────────────────────────────────────

  @observable
  String searchQuery = '';
  
  @observable
  bool? hasProducts;

  // ── Sort ───────────────────────────────────────────────────────────────────

  @observable
  String? sortBy;

  @observable
  String? sortOrder;

  // ── Selected supplier detail ───────────────────────────────────────────────

  @observable
  Supplier? currentSupplier;

  // ── Async state ────────────────────────────────────────────────────────────

  @observable
  bool isLoading = false;

  @observable
  bool isSubmitting = false;

  @observable
  String? errorMessage;

  // ── Private ────────────────────────────────────────────────────────────────

  Timer? _searchDebounce;

  // ── Computed ───────────────────────────────────────────────────────────────

  @computed
  bool get hasNextPage => currentPage < totalPages;

  @computed
  bool get hasPreviousPage => currentPage > 1;

  // ── Supplier list actions ──────────────────────────────────────────────────

  @action
  Future<void> fetchSuppliers({int page = 1}) async {
    isLoading = true;
    errorMessage = null;
    try {
      final result = await _getSuppliers(
        search: searchQuery,
        page: page,
        pageSize: pageSize,
        hasProducts: hasProducts,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      suppliers = ObservableList.of(result.data);
      currentPage = result.page;
      totalItems = result.totalItems;
      totalPages = result.totalPages;
    } catch (e) {
      errorMessage = _parseError(e);
    } finally {
      isLoading = false;
    }
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchSuppliers(page: 1);
    });
  }

  @action
  Future<void> setFilters({bool? hasProducts}) async {
    this.hasProducts = hasProducts;
    await fetchSuppliers(page: 1);
  }

  @action
  Future<void> nextPage() async {
    if (hasNextPage) await fetchSuppliers(page: currentPage + 1);
  }

  @action
  Future<void> previousPage() async {
    if (hasPreviousPage) await fetchSuppliers(page: currentPage - 1);
  }

  @action
  Future<void> setSort({String? sortBy, String? sortOrder}) async {
    this.sortBy = sortBy;
    this.sortOrder = sortOrder;
    await fetchSuppliers(page: 1);
  }

  @action
  void resetSort() {
    sortBy = null;
    sortOrder = null;
  }

  @action
  void resetFilters() {
    hasProducts = null;
    searchQuery = '';
  }

  // ── Supplier detail ────────────────────────────────────────────────────────

  @action
  Future<void> loadSupplierById(String id) async {
    isLoading = true;
    errorMessage = null;
    try {
      currentSupplier = await _getSupplierById(id);
    } catch (e) {
      errorMessage = _parseError(e);
    } finally {
      isLoading = false;
    }
  }

  // ── Supplier CRUD ──────────────────────────────────────────────────────────

  @action
  Future<bool> addSupplier(SupplierUpsertPayload payload) async {
    isSubmitting = true;
    errorMessage = null;
    try {
      await _createSupplier(payload);
      await fetchSuppliers(page: currentPage);
      isSubmitting = false;
      return true;
    } catch (e) {
      errorMessage = _parseError(e);
      isSubmitting = false;
      return false;
    }
  }

  @action
  Future<bool> updateSupplier(String id, SupplierUpsertPayload payload) async {
    isSubmitting = true;
    errorMessage = null;
    try {
      final updated = await _updateSupplier(id, payload);
      if (currentSupplier?.id == id) currentSupplier = updated;
      await fetchSuppliers(page: currentPage);
      isSubmitting = false;
      return true;
    } catch (e) {
      errorMessage = _parseError(e);
      isSubmitting = false;
      return false;
    }
  }

  @action
  Future<bool> deleteSupplier(String id) async {
    isSubmitting = true;
    errorMessage = null;
    try {
      await _deleteSupplier(id);
      if (currentSupplier?.id == id) currentSupplier = null;
      final targetPage =
          currentPage > 1 && suppliers.length <= 1 ? currentPage - 1 : currentPage;
      await fetchSuppliers(page: targetPage);
      isSubmitting = false;
      return true;
    } catch (e) {
      errorMessage = _parseError(e);
      isSubmitting = false;
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearError() => errorMessage = null;

  String _parseError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String) return message;
        if (message is List) return message.join(', ');
        final errorObj = data['error'];
        if (errorObj is Map<String, dynamic>) {
          final nestedMessage = errorObj['message'];
          if (nestedMessage is String) return nestedMessage;
          if (nestedMessage is List) return nestedMessage.join(', ');
        }
      }
      if (data is String && data.isNotEmpty) return data;
      switch (error.response?.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Session expired. Please log in again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Supplier not found.';
        case 409:
          return 'Cannot complete this action due to a conflict.';
        default:
          return 'An unexpected error occurred. Please try again.';
      }
    }
    return error.toString();
  }
}
