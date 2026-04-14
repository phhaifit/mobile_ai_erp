import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_values_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/update_attribute_value_usecase.dart';
import 'package:mobx/mobx.dart';

part 'attribute_value_store.g.dart';

class AttributeValueStore = AttributeValueStoreBase with _$AttributeValueStore;

/// Store for managing AttributeValue items (NOT to be confused with "options")
/// Handles CRUD operations for values within an AttributeSet
abstract class AttributeValueStoreBase with Store {
  AttributeValueStoreBase({
    required GetAttributeValuesUseCase getAttributeValuesUseCase,
    required CreateAttributeValueUseCase createAttributeValueUseCase,
    required UpdateAttributeValueUseCase updateAttributeValueUseCase,
    required DeleteAttributeValueUseCase deleteAttributeValueUseCase,
    required this.errorStore,
  })  : _getAttributeValuesUseCase = getAttributeValuesUseCase,
        _createAttributeValueUseCase = createAttributeValueUseCase,
        _updateAttributeValueUseCase = updateAttributeValueUseCase,
        _deleteAttributeValueUseCase = deleteAttributeValueUseCase;

  final GetAttributeValuesUseCase _getAttributeValuesUseCase;
  final CreateAttributeValueUseCase _createAttributeValueUseCase;
  final UpdateAttributeValueUseCase _updateAttributeValueUseCase;
  final DeleteAttributeValueUseCase _deleteAttributeValueUseCase;

  final ErrorStore errorStore;

  @observable
  ObservableList<AttributeValue> values = ObservableList<AttributeValue>();

  @observable
  String? activeAttributeSetId;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  /// Load values for a specific AttributeSet (sorted by sortOrder from backend)
  @action
  Future<void> loadAttributeValues(String attributeSetId) async {
    isLoading = true;
    error = null;
    try {
      final result = await _getAttributeValuesUseCase.call(
        params: attributeSetId,
      );
      values = ObservableList.of(result);
      activeAttributeSetId = attributeSetId;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Create a new AttributeValue
  @action
  Future<void> createAttributeValue(AttributeValue value) async {
    isLoading = true;
    error = null;
    try {
      final created = await _createAttributeValueUseCase.call(params: value);
      if (created.attributeSetId == activeAttributeSetId) {
        values.add(created);
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Update an existing AttributeValue
  @action
  Future<void> updateAttributeValue(AttributeValue value) async {
    isLoading = true;
    error = null;
    try {
      final updated = await _updateAttributeValueUseCase.call(params: value);
      final index = values.indexWhere((v) => v.id == value.id);
      if (index >= 0) {
        values[index] = updated;
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Delete an AttributeValue by ID
  @action
  Future<void> deleteAttributeValue(String attributeSetId, String valueId) async {
    isLoading = true;
    error = null;
    try {
      await _deleteAttributeValueUseCase.call(
        params: DeleteAttributeValueParams(
          attributeSetId: attributeSetId,
          valueId: valueId,
        ),
      );
      values.removeWhere((v) => v.id == valueId);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Clear active set and values
  @action
  void clearActiveSet() {
    activeAttributeSetId = null;
    values.clear();
  }
}
