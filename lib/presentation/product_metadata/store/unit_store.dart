import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/units/create_unit_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/units/delete_unit_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/units/get_units_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/units/update_unit_usecase.dart';
import 'package:mobx/mobx.dart';

part 'unit_store.g.dart';

class UnitStore = UnitStoreBase with _$UnitStore;

abstract class UnitStoreBase with Store {
  UnitStoreBase({
    required GetUnitsUseCase getUnitsUseCase,
    required CreateUnitUseCase createUnitUseCase,
    required UpdateUnitUseCase updateUnitUseCase,
    required DeleteUnitUseCase deleteUnitUseCase,
    required this.errorStore,
  }) : _getUnitsUseCase = getUnitsUseCase,
       _createUnitUseCase = createUnitUseCase,
       _updateUnitUseCase = updateUnitUseCase,
       _deleteUnitUseCase = deleteUnitUseCase;

  final GetUnitsUseCase _getUnitsUseCase;
  final CreateUnitUseCase _createUnitUseCase;
  final UpdateUnitUseCase _updateUnitUseCase;
  final DeleteUnitUseCase _deleteUnitUseCase;

  final ErrorStore errorStore;

  @observable
  ObservableList<Unit> units = ObservableList<Unit>();

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
  Future<void> loadUnits({
    int page = 1,
    int pageSize = 10,
    String? search,
    bool includeInactive = false,
    String? sortBy,
    String? sortOrder,
  }) async {
    await _runWithLoading(() async {
      try {
        final result = await _getUnitsUseCase.call(
          params: GetUnitsParams(
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
  Future<Unit> createUnit(Unit unit) async {
    return await _runWithLoading(() async {
      try {
        final result = await _createUnitUseCase.call(params: unit);
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
  Future<Unit> updateUnit(Unit unit) async {
    return await _runWithLoading(() async {
      try {
        final result = await _updateUnitUseCase.call(params: unit);
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
  Future<void> deleteUnit(String unitId) async {
    await _runWithLoading(() async {
      try {
        await _deleteUnitUseCase.call(params: unitId);
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
      final result = await _getUnitsUseCase.call(
        params: GetUnitsParams(
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
  void _applyMetadataPage(MetadataPage<Unit> page) {
    units = ObservableList.of(page.items);
    currentPage = page.page;
    pageSize = page.pageSize;
    totalItems = page.totalItems;
    totalPages = page.totalPages;
  }
}
