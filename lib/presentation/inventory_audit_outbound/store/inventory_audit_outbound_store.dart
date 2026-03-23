import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_warehouse.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_audit_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_by_warehouse_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_outbound_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_warehouses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/save_inventory_audit_session_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/submit_inventory_outbound_usecase.dart';

part 'inventory_audit_outbound_store.g.dart';

class InventoryAuditOutboundStore = _InventoryAuditOutboundStore
    with _$InventoryAuditOutboundStore;

abstract class _InventoryAuditOutboundStore with Store {
  _InventoryAuditOutboundStore(
    this._getInventoryWarehousesUseCase,
    this._getInventoryByWarehouseUseCase,
    this._saveInventoryAuditSessionUseCase,
    this._getInventoryAuditRecordsUseCase,
    this._submitInventoryOutboundUseCase,
    this._getInventoryOutboundRecordsUseCase,
  );

  final GetInventoryWarehousesUseCase _getInventoryWarehousesUseCase;
  final GetInventoryByWarehouseUseCase _getInventoryByWarehouseUseCase;
  final SaveInventoryAuditSessionUseCase _saveInventoryAuditSessionUseCase;
  final GetInventoryAuditRecordsUseCase _getInventoryAuditRecordsUseCase;
  final SubmitInventoryOutboundUseCase _submitInventoryOutboundUseCase;
  final GetInventoryOutboundRecordsUseCase _getInventoryOutboundRecordsUseCase;
  int _selectedWarehouseRequestId = 0;

  @observable
  bool isLoading = false;

  @observable
  bool isSubmitting = false;

  @observable
  String errorMessage = '';

  @observable
  ObservableList<InventoryWarehouse> warehouses =
      ObservableList<InventoryWarehouse>();

  @observable
  ObservableList<InventoryItem> inventoryItems = ObservableList<InventoryItem>();

  @observable
  ObservableList<AuditRecord> auditRecords = ObservableList<AuditRecord>();

  @observable
  ObservableList<OutboundRecord> outboundRecords =
      ObservableList<OutboundRecord>();

  @observable
  ObservableList<InventoryItem> outboundInventoryItems =
      ObservableList<InventoryItem>();

  @observable
  String? selectedWarehouseId;

  @observable
  String? selectedAuditProductId;

  @observable
  ObservableMap<String, String> physicalCountInputs = ObservableMap<String, String>();

  @observable
  String? outboundWarehouseId;

  @observable
  String? outboundProductId;

  @observable
  String outboundQuantityInput = '';

  @observable
  String outboundNote = '';

  @computed
  int? get outboundQuantity => int.tryParse(outboundQuantityInput);

  @computed
  List<AuditLine> get auditLines => inventoryItems
      .map(
        (item) {
          final physical = getResolvedPhysicalCount(item);
          return AuditLine(
            productId: item.productId,
            productName: item.productName,
            systemQty: item.systemQty,
            physicalQty: physical,
            discrepancy: physical - item.systemQty,
            unit: item.unit,
          );
        },
      )
      .toList(growable: false);

  @computed
  int get mismatchCount => auditLines.where((line) => line.discrepancy != 0).length;

  @computed
  int get totalAbsoluteDiscrepancy => auditLines.fold<int>(
        0,
        (sum, line) => sum + line.discrepancy.abs(),
      );

  @computed
  List<InventoryItem> get availableProductsForOutbound {
    final warehouseId = outboundWarehouseId;
    if (warehouseId == null) {
      return const <InventoryItem>[];
    }
    return outboundInventoryItems
        .where((item) => item.warehouseId == warehouseId)
        .toList(growable: false);
  }

  @computed
  InventoryItem? get selectedOutboundItem {
    final productId = outboundProductId;
    if (productId == null) {
      return null;
    }
    for (final item in availableProductsForOutbound) {
      if (item.productId == productId) {
        return item;
      }
    }
    return null;
  }

  @computed
  bool get allCountsFilledAndValid {
    if (inventoryItems.isEmpty) {
      return false;
    }

    for (final item in inventoryItems) {
      final raw = physicalCountInputs[item.productId];
      if (raw == null || raw.trim().isEmpty) {
        return false;
      }
      final parsed = int.tryParse(raw.trim());
      if (parsed == null || parsed < 0) {
        return false;
      }
    }
    return true;
  }

  @computed
  bool get canSaveAudit =>
      selectedWarehouseId != null &&
      inventoryItems.isNotEmpty &&
      allCountsFilledAndValid;

  @computed
  bool get canSubmitOutbound {
    final warehouseId = outboundWarehouseId;
    final productId = outboundProductId;
    final qty = outboundQuantity;
    final selectedItem = selectedOutboundItem;

    if (warehouseId == null || productId == null || qty == null || qty <= 0) {
      return false;
    }
    if (selectedItem == null) {
      return false;
    }
    return qty <= selectedItem.systemQty;
  }

  @action
  Future<void> loadInitialData() async {
    isLoading = true;
    clearError();

    try {
      final loadedWarehouses = await _getInventoryWarehousesUseCase.call(params: null);
      final loadedAuditRecords = await _getInventoryAuditRecordsUseCase.call(params: null);
      final loadedOutboundRecords =
          await _getInventoryOutboundRecordsUseCase.call(params: null);

      warehouses = ObservableList<InventoryWarehouse>.of(loadedWarehouses);
      auditRecords = ObservableList<AuditRecord>.of(loadedAuditRecords);
      outboundRecords = ObservableList<OutboundRecord>.of(loadedOutboundRecords);

      if (loadedWarehouses.isNotEmpty) {
        await setSelectedWarehouse(loadedWarehouses.first.id);
        await setOutboundWarehouse(loadedWarehouses.first.id);
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> setSelectedWarehouse(String? warehouseId) async {
    final requestId = ++_selectedWarehouseRequestId;
    selectedWarehouseId = warehouseId;
    selectedAuditProductId = null;
    physicalCountInputs.clear();
    inventoryItems = ObservableList<InventoryItem>();

    if (warehouseId == null) {
      return;
    }

    final loadedInventory =
        await _getInventoryByWarehouseUseCase.call(params: warehouseId);
    if (requestId != _selectedWarehouseRequestId || selectedWarehouseId != warehouseId) {
      return;
    }

    runInAction(() {
      inventoryItems = ObservableList<InventoryItem>.of(loadedInventory);
      selectedAuditProductId =
          loadedInventory.isNotEmpty ? loadedInventory.first.productId : null;
    });
  }

  @action
  void setSelectedAuditProduct(String? productId) {
    selectedAuditProductId = productId;
  }

  @action
  void setPhysicalCount(String productId, String input) {
    physicalCountInputs[productId] = input;
  }

  String getPhysicalCountInput(String productId) => physicalCountInputs[productId] ?? '';

  int getResolvedPhysicalCount(InventoryItem item) {
    final input = physicalCountInputs[item.productId];
    final parsed = int.tryParse(input ?? '');
    return parsed ?? item.systemQty;
  }

  @action
  Future<bool> saveAuditSession() async {
    if (!canSaveAudit || selectedWarehouseId == null) {
      errorMessage = 'Select a warehouse to save audit.';
      return false;
    }

    isSubmitting = true;
    clearError();

    try {
      final record = await _saveInventoryAuditSessionUseCase.call(
        params: SaveInventoryAuditSessionParams(
          warehouseId: selectedWarehouseId!,
          lines: auditLines,
        ),
      );

      auditRecords.insert(0, record);
      await _reloadInventoryForSelectedWarehouse();
      physicalCountInputs.clear();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  @action
  Future<void> setOutboundWarehouse(String? warehouseId) async {
    outboundWarehouseId = warehouseId;
    outboundProductId = null;

    if (warehouseId == null) {
      outboundInventoryItems.clear();
      return;
    }

    final loadedInventory =
        await _getInventoryByWarehouseUseCase.call(params: warehouseId);
    outboundInventoryItems = ObservableList<InventoryItem>.of(loadedInventory);
  }

  @action
  void setOutboundProduct(String? productId) {
    outboundProductId = productId;
  }

  @action
  void setOutboundQuantity(String value) {
    outboundQuantityInput = value;
  }

  @action
  void setOutboundNote(String value) {
    outboundNote = value;
  }

  @action
  Future<bool> submitOutbound() async {
    if (!canSubmitOutbound) {
      errorMessage = 'Outbound form has invalid values.';
      return false;
    }

    isSubmitting = true;
    clearError();

    try {
      final record = await _submitInventoryOutboundUseCase.call(
        params: SubmitInventoryOutboundParams(
          warehouseId: outboundWarehouseId!,
          productId: outboundProductId!,
          quantity: outboundQuantity!,
          note: outboundNote.isEmpty ? null : outboundNote,
        ),
      );
      outboundRecords.insert(0, record);

      if (selectedWarehouseId == outboundWarehouseId) {
        await _reloadInventoryForSelectedWarehouse();
      }
      await _reloadOutboundInventory();
      _resetOutboundForm();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  String getWarehouseName(String? warehouseId) {
    if (warehouseId == null) {
      return '-';
    }
    for (final warehouse in warehouses) {
      if (warehouse.id == warehouseId) {
        return warehouse.name;
      }
    }
    return '-';
  }

  InventoryItem? getSelectedAuditItem() {
    final selectedProductId = selectedAuditProductId;
    if (selectedProductId == null) {
      return null;
    }
    for (final item in inventoryItems) {
      if (item.productId == selectedProductId) {
        return item;
      }
    }
    return null;
  }

  @action
  void clearError() {
    errorMessage = '';
  }

  Future<void> _reloadInventoryForSelectedWarehouse() async {
    final warehouseId = selectedWarehouseId;
    if (warehouseId == null) {
      return;
    }
    final loadedInventory =
        await _getInventoryByWarehouseUseCase.call(params: warehouseId);
    inventoryItems = ObservableList<InventoryItem>.of(loadedInventory);
  }

  Future<void> _reloadOutboundInventory() async {
    final warehouseId = outboundWarehouseId;
    if (warehouseId == null) {
      return;
    }
    final loadedInventory =
        await _getInventoryByWarehouseUseCase.call(params: warehouseId);
    outboundInventoryItems = ObservableList<InventoryItem>.of(loadedInventory);
  }

  @action
  void _resetOutboundForm() {
    outboundProductId = null;
    outboundQuantityInput = '';
    outboundNote = '';
  }
}
