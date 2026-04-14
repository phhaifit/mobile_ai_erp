import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_sets_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/update_attribute_set_usecase.dart';
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
    required GetAllAttributeValuesUseCase getAllAttributeValuesUseCase,
    required this.errorStore,
  })  : _getAttributeSetsUseCase = getAttributeSetsUseCase,
        _createAttributeSetUseCase = createAttributeSetUseCase,
        _updateAttributeSetUseCase = updateAttributeSetUseCase,
        _deleteAttributeSetUseCase = deleteAttributeSetUseCase,
        _createAttributeValueUseCase = createAttributeValueUseCase,
        _updateAttributeValueUseCase = updateAttributeValueUseCase,
        _deleteAttributeValueUseCase = deleteAttributeValueUseCase,
        _getAllAttributeValuesUseCase = getAllAttributeValuesUseCase;

  final GetAttributeSetsUseCase _getAttributeSetsUseCase;
  final CreateAttributeSetUseCase _createAttributeSetUseCase;
  final UpdateAttributeSetUseCase _updateAttributeSetUseCase;
  final DeleteAttributeSetUseCase _deleteAttributeSetUseCase;
  final CreateAttributeValueUseCase _createAttributeValueUseCase;
  final UpdateAttributeValueUseCase _updateAttributeValueUseCase;
  final DeleteAttributeValueUseCase _deleteAttributeValueUseCase;
  final GetAllAttributeValuesUseCase _getAllAttributeValuesUseCase;

  final ErrorStore errorStore;

  // ============================================================================
  // AttributeSet State
  // ============================================================================

  @observable
  ObservableList<AttributeSet> attributeSets = ObservableList<AttributeSet>();

  @observable
  ObservableList<AttributeValue> allAttributeValues = ObservableList<AttributeValue>();

  @observable
  int currentPage = 1;

  @observable
  int pageSize = 20;

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
  String? sortBy;

  @observable
  String? sortOrder;

  // ============================================================================
  // AttributeSet Actions
  // ============================================================================

  @action
  Future<void> loadAttributeSets({
    int page = 1,
    int pageSize = 20,
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
  Future<void> createAttributeSet(AttributeSet attributeSet) async {
    await _runWithLoading(() async {
      try {
        await _createAttributeSetUseCase.call(
          params: attributeSet,
        );
        await _reloadCurrentQuery();
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<void> updateAttributeSet(AttributeSet attributeSet) async {
    await _runWithLoading(() async {
      try {
        await _updateAttributeSetUseCase.call(
          params: attributeSet,
        );
        await _reloadCurrentQuery();
        error = null;
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
  Future<void> createAttributeValue(AttributeValue value) async {
    await _runWithLoading(() async {
      try {
        final result = await _createAttributeValueUseCase.call(params: value);
        
        // Update in attributeSets
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
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<void> updateAttributeValue(AttributeValue value) async {
    await _runWithLoading(() async {
      try {
        final result = await _updateAttributeValueUseCase.call(params: value);
        
        // Update in attributeSets
        final setIndex = attributeSets.indexWhere(
          (set) => set.id == value.attributeSetId,
        );
        if (setIndex >= 0) {
          final updatedSet = attributeSets[setIndex];
          final valueIndex = updatedSet.values.indexWhere(
            (v) => v.id == value.id,
          );
          if (valueIndex >= 0) {
            attributeSets[setIndex] = updatedSet.copyWith(
              values: [
                ...updatedSet.values.sublist(0, valueIndex),
                result,
                ...updatedSet.values.sublist(valueIndex + 1),
              ],
            );
          }
        }
        
        error = null;
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
        
        // Update in attributeSets
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

  Future<void> _runWithLoading(Future<void> Function() fn) async {
    isLoading = true;
    try {
      await fn();
    } finally {
      isLoading = false;
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
