import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_sets_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/update_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_values_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/update_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_all_attribute_values_usecase.dart';
import 'package:mobx/mobx.dart';

part 'attribute_set_store.g.dart';

class AttributeSetStore = AttributeSetStoreBase with _$AttributeSetStore;

abstract class AttributeSetStoreBase with Store {
  AttributeSetStoreBase({
    required GetAttributeSetsUseCase getAttributeSetsUseCase,
    required CreateAttributeSetUseCase createAttributeSetUseCase,
    required UpdateAttributeSetUseCase updateAttributeSetUseCase,
    required DeleteAttributeSetUseCase deleteAttributeSetUseCase,
    required CreateAttributeValueUseCase createAttributeValueUseCase,
    required UpdateAttributeValueUseCase updateAttributeValueUseCase,
    required DeleteAttributeValueUseCase deleteAttributeValueUseCase,
    required GetAttributeValuesUseCase getAttributeValuesUseCase,
    required GetAllAttributeValuesUseCase getAllAttributeValuesUseCase,
    required this.errorStore,
  })  : _getAttributeSetsUseCase = getAttributeSetsUseCase,
        _createAttributeSetUseCase = createAttributeSetUseCase,
        _updateAttributeSetUseCase = updateAttributeSetUseCase,
        _deleteAttributeSetUseCase = deleteAttributeSetUseCase,
        _createAttributeValueUseCase = createAttributeValueUseCase,
        _updateAttributeValueUseCase = updateAttributeValueUseCase,
        _deleteAttributeValueUseCase = deleteAttributeValueUseCase,
        _getAttributeValuesUseCase = getAttributeValuesUseCase,
        _getAllAttributeValuesUseCase = getAllAttributeValuesUseCase;

  final GetAttributeSetsUseCase _getAttributeSetsUseCase;
  final CreateAttributeSetUseCase _createAttributeSetUseCase;
  final UpdateAttributeSetUseCase _updateAttributeSetUseCase;
  final DeleteAttributeSetUseCase _deleteAttributeSetUseCase;
  final CreateAttributeValueUseCase _createAttributeValueUseCase;
  final UpdateAttributeValueUseCase _updateAttributeValueUseCase;
  final DeleteAttributeValueUseCase _deleteAttributeValueUseCase;
  final GetAttributeValuesUseCase _getAttributeValuesUseCase;
  final GetAllAttributeValuesUseCase _getAllAttributeValuesUseCase;

  final ErrorStore errorStore;

  // ============================================================================
  // AttributeSet State
  // ============================================================================

  @observable
  ObservableList<AttributeSet> attributeSets = ObservableList<AttributeSet>();

  @observable
  ObservableList<AttributeValue> attributeValues = ObservableList<AttributeValue>();

  @observable
  ObservableList<AttributeValue> allAttributeValues = ObservableList<AttributeValue>();

  @observable
  String? activeAttributeSetId;

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

  @observable
  String? searchQuery;

  @observable
  String? sortBy;

  @observable
  String? sortOrder;

  // ============================================================================
  // AttributeSet Actions
  // ============================================================================

  @action
  Future<void> loadAttributeSets({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    await _runWithLoading(() async {
      try {
        final result = await _getAttributeSetsUseCase.call(
          params: GetAttributeSetsParams(
            page: page,
            pageSize: pageSize,
            search: search,
            sortBy: sortBy,
            sortOrder: sortOrder,
          ),
        );
        _applyMetadataPage(result);
        searchQuery = search;
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
  Future<void> loadAllAttributeValues() async {
    await _runWithLoading(() async {
      try {
        final result = await _getAllAttributeValuesUseCase.call(params: null);
        allAttributeValues = ObservableList.of(result);
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<AttributeSet> createAttributeSet(AttributeSet attributeSet) async {
    return await _runWithLoading(() async {
      try {
        final result = await _createAttributeSetUseCase.call(
          params: attributeSet,
        );
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
  Future<AttributeSet> updateAttributeSet(AttributeSet attributeSet) async {
    return await _runWithLoading(() async {
      try {
        final result = await _updateAttributeSetUseCase.call(
          params: attributeSet,
        );
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
  Future<void> deleteAttributeSet(String attributeSetId) async {
    await _runWithLoading(() async {
      try {
        await _deleteAttributeSetUseCase.call(params: attributeSetId);
        await _reloadCurrentQuery();
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  // ============================================================================
  // AttributeValue Actions
  // ============================================================================

  @action
  Future<void> loadAttributeValues(String attributeSetId) async {
    await _runWithLoading(() async {
      try {
        final result = await _getAttributeValuesUseCase.call(
          params: attributeSetId,
        );
        attributeValues = ObservableList.of(result);
        activeAttributeSetId = attributeSetId;
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<AttributeValue> createAttributeValue(AttributeValue value) async {
    return await _runWithLoading(() async {
      try {
        final result = await _createAttributeValueUseCase.call(params: value);

        // Update in active list if viewing the same set
        if (value.attributeSetId == activeAttributeSetId) {
          attributeValues.add(result);
        }

        // Update in main attributeSets list (Find set and update nested values)
        final setIndex = attributeSets.indexWhere(
          (set) => set.id == value.attributeSetId,
        );
        if (setIndex >= 0) {
          final updatedSet = attributeSets[setIndex];
          attributeSets[setIndex] = updatedSet.copyWith(
            values: [...updatedSet.values, result],
          );
        }

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
  Future<AttributeValue> updateAttributeValue(AttributeValue value) async {
    return await _runWithLoading(() async {
      try {
        final result = await _updateAttributeValueUseCase.call(params: value);

        // Update in active list
        final valIndex = attributeValues.indexWhere((v) => v.id == value.id);
        if (valIndex >= 0) {
          attributeValues[valIndex] = result;
        }

        // Update in main list
        final setIndex = attributeSets.indexWhere(
          (set) => set.id == value.attributeSetId,
        );
        if (setIndex >= 0) {
          final updatedSet = attributeSets[setIndex];
          final valueIndex = updatedSet.values.indexWhere(
            (v) => v.id == value.id,
          );
          if (valueIndex >= 0) {
            final updatedValues = [...updatedSet.values];
            updatedValues[valueIndex] = result;
            attributeSets[setIndex] = updatedSet.copyWith(
              values: updatedValues,
            );
          }
        }

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
  Future<void> deleteAttributeValue(
    String attributeSetId,
    String valueId,
  ) async {
    await _runWithLoading(() async {
      try {
        await _deleteAttributeValueUseCase.call(
          params: DeleteAttributeValueParams(
            attributeSetId: attributeSetId,
            valueId: valueId,
          ),
        );

        // Update in active list
        attributeValues.removeWhere((v) => v.id == valueId);

        // Update in main list
        final setIndex = attributeSets.indexWhere(
          (set) => set.id == attributeSetId,
        );
        if (setIndex >= 0) {
          final updatedSet = attributeSets[setIndex];
          attributeSets[setIndex] = updatedSet.copyWith(
            values: updatedSet.values
                .where((v) => v.id != valueId)
                .toList(),
          );
        }

        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
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
      final result = await _getAttributeSetsUseCase.call(
        params: GetAttributeSetsParams(
          page: currentPage,
          pageSize: pageSize,
          search: searchQuery,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ),
      );
      _applyMetadataPage(result);
    });
  }

  @action
  void _applyMetadataPage(MetadataPage<AttributeSet> page) {
    attributeSets = ObservableList.of(page.items);
    currentPage = page.page;
    pageSize = page.pageSize;
    totalItems = page.totalItems;
    totalPages = page.totalPages;
  }
}
