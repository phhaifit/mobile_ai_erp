import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_warehouse.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobx/mobx.dart';

class InventoryAuditOutboundStore {
  InventoryAuditOutboundStore(this._repository)
      : _auditLines = Computed<List<AuditLine>>(() => const []),
        _mismatchCount = Computed<int>(() => 0),
        _totalAbsoluteDiscrepancy = Computed<int>(() => 0),
        _availableProductsForOutbound = Computed<List<InventoryItem>>(
          () => const [],
        ),
        _selectedOutboundItem = Computed<InventoryItem?>(() => null),
        _canSubmitOutbound = Computed<bool>(() => false),
        _canSaveAudit = Computed<bool>(() => false) {
    _auditLines = Computed<List<AuditLine>>(_computeAuditLines);
    _mismatchCount = Computed<int>(
      () => auditLines.where((line) => line.discrepancy != 0).length,
    );
    _totalAbsoluteDiscrepancy = Computed<int>(
      () => auditLines.fold<int>(
        0,
        (sum, line) => sum + line.discrepancy.abs(),
      ),
    );
    _availableProductsForOutbound = Computed<List<InventoryItem>>(
      _computeAvailableProductsForOutbound,
    );
    _selectedOutboundItem = Computed<InventoryItem?>(_computeSelectedOutboundItem);
    _canSubmitOutbound = Computed<bool>(_computeCanSubmitOutbound);
    _canSaveAudit = Computed<bool>(
      () => selectedWarehouseId != null && inventoryItems.isNotEmpty,
    );
  }

  final InventoryAuditOutboundRepository _repository;

  final ObservableList<InventoryWarehouse> warehouses =
      ObservableList<InventoryWarehouse>();
  final ObservableList<InventoryItem> inventoryItems =
      ObservableList<InventoryItem>();
  final ObservableList<AuditRecord> auditRecords = ObservableList<AuditRecord>();
  final ObservableList<OutboundRecord> outboundRecords =
      ObservableList<OutboundRecord>();
  final ObservableList<InventoryItem> outboundInventoryItems =
      ObservableList<InventoryItem>();

  final Observable<bool> _isLoading = Observable(false);
  final Observable<bool> _isSubmitting = Observable(false);
  final Observable<String> _errorMessage = Observable('');

  final Observable<String?> _selectedWarehouseId = Observable(null);
  final Observable<String?> _selectedAuditProductId = Observable(null);
  final ObservableMap<String, String> _physicalCountInputs =
      ObservableMap<String, String>();

  final Observable<String?> _outboundWarehouseId = Observable(null);
  final Observable<String?> _outboundProductId = Observable(null);
  final Observable<String> _outboundQuantityInput = Observable('');
  final Observable<String> _outboundNote = Observable('');

  late Computed<List<AuditLine>> _auditLines;
  late Computed<int> _mismatchCount;
  late Computed<int> _totalAbsoluteDiscrepancy;
  late Computed<List<InventoryItem>> _availableProductsForOutbound;
  late Computed<InventoryItem?> _selectedOutboundItem;
  late Computed<bool> _canSubmitOutbound;
  late Computed<bool> _canSaveAudit;

  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  String get errorMessage => _errorMessage.value;

  String? get selectedWarehouseId => _selectedWarehouseId.value;
  String? get selectedAuditProductId => _selectedAuditProductId.value;

  String? get outboundWarehouseId => _outboundWarehouseId.value;
  String? get outboundProductId => _outboundProductId.value;
  String get outboundQuantityInput => _outboundQuantityInput.value;
  String get outboundNote => _outboundNote.value;

  List<AuditLine> get auditLines => _auditLines.value;
  int get mismatchCount => _mismatchCount.value;
  int get totalAbsoluteDiscrepancy => _totalAbsoluteDiscrepancy.value;
  List<InventoryItem> get availableProductsForOutbound =>
      _availableProductsForOutbound.value;
  InventoryItem? get selectedOutboundItem => _selectedOutboundItem.value;
  bool get canSubmitOutbound => _canSubmitOutbound.value;
  bool get canSaveAudit => _canSaveAudit.value;

  int? get outboundQuantity => int.tryParse(_outboundQuantityInput.value);

  Future<void> loadInitialData() async {
    _setLoading(true);
    clearError();

    try {
      final loadedWarehouses = await _repository.getWarehouses();
      final loadedAuditRecords = await _repository.getAuditRecords();
      final loadedOutboundRecords = await _repository.getOutboundRecords();

      runInAction(() {
        warehouses
          ..clear()
          ..addAll(loadedWarehouses);

        auditRecords
          ..clear()
          ..addAll(loadedAuditRecords);

        outboundRecords
          ..clear()
          ..addAll(loadedOutboundRecords);
      });

      if (loadedWarehouses.isNotEmpty) {
        await setSelectedWarehouse(loadedWarehouses.first.id);
        await setOutboundWarehouse(loadedWarehouses.first.id);
      }
    } catch (error) {
      _setError(error.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSelectedWarehouse(String? warehouseId) async {
    runInAction(() {
      _selectedWarehouseId.value = warehouseId;
      _selectedAuditProductId.value = null;
      _physicalCountInputs.clear();
    });

    if (warehouseId == null) {
      runInAction(() {
        inventoryItems.clear();
      });
      return;
    }

    final loadedInventory = await _repository.getInventoryByWarehouse(warehouseId);

    runInAction(() {
      inventoryItems
        ..clear()
        ..addAll(loadedInventory);
      if (loadedInventory.isNotEmpty) {
        _selectedAuditProductId.value = loadedInventory.first.productId;
      }
    });
  }

  void setSelectedAuditProduct(String? productId) {
    runInAction(() {
      _selectedAuditProductId.value = productId;
    });
  }

  void setPhysicalCount(String productId, String input) {
    runInAction(() {
      _physicalCountInputs[productId] = input;
    });
  }

  String getPhysicalCountInput(String productId) {
    return _physicalCountInputs[productId] ?? '';
  }

  int getResolvedPhysicalCount(InventoryItem item) {
    final input = _physicalCountInputs[item.productId];
    final parsed = int.tryParse(input ?? '');
    return parsed ?? item.systemQty;
  }

  Future<bool> saveAuditSession() async {
    if (!canSaveAudit || selectedWarehouseId == null) {
      _setError('Select a warehouse to save audit.');
      return false;
    }

    _setSubmitting(true);
    clearError();

    try {
      final record = await _repository.saveAuditSession(
        warehouseId: selectedWarehouseId!,
        lines: auditLines,
      );

      runInAction(() {
        auditRecords.insert(0, record);
      });

      await _reloadInventoryForSelectedWarehouse();
      runInAction(() {
        _physicalCountInputs.clear();
      });
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> setOutboundWarehouse(String? warehouseId) async {
    runInAction(() {
      _outboundWarehouseId.value = warehouseId;
      _outboundProductId.value = null;
    });

    if (warehouseId == null) {
      runInAction(() {
        outboundInventoryItems.clear();
      });
      return;
    }

    final loadedInventory = await _repository.getInventoryByWarehouse(warehouseId);
    runInAction(() {
      outboundInventoryItems
        ..clear()
        ..addAll(loadedInventory);
    });
  }

  void setOutboundProduct(String? productId) {
    runInAction(() {
      _outboundProductId.value = productId;
    });
  }

  void setOutboundQuantity(String value) {
    runInAction(() {
      _outboundQuantityInput.value = value;
    });
  }

  void setOutboundNote(String value) {
    runInAction(() {
      _outboundNote.value = value;
    });
  }

  Future<bool> submitOutbound() async {
    if (!canSubmitOutbound) {
      _setError('Outbound form has invalid values.');
      return false;
    }

    _setSubmitting(true);
    clearError();

    try {
      final record = await _repository.submitOutbound(
        warehouseId: outboundWarehouseId!,
        productId: outboundProductId!,
        quantity: outboundQuantity!,
        note: outboundNote.isEmpty ? null : outboundNote,
      );

      runInAction(() {
        outboundRecords.insert(0, record);
      });

      if (selectedWarehouseId == outboundWarehouseId) {
        await _reloadInventoryForSelectedWarehouse();
      }
      await _reloadOutboundInventory();

      _resetOutboundForm();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setSubmitting(false);
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

  void clearError() {
    runInAction(() {
      _errorMessage.value = '';
    });
  }

  List<AuditLine> _computeAuditLines() {
    return inventoryItems
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
  }

  List<InventoryItem> _computeAvailableProductsForOutbound() {
    final warehouseId = outboundWarehouseId;
    if (warehouseId == null) {
      return const [];
    }

    return outboundInventoryItems
        .where((item) => item.warehouseId == warehouseId)
        .toList(growable: false);
  }

  InventoryItem? _computeSelectedOutboundItem() {
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

  bool _computeCanSubmitOutbound() {
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

  Future<void> _reloadInventoryForSelectedWarehouse() async {
    final warehouseId = selectedWarehouseId;
    if (warehouseId == null) {
      return;
    }

    final loadedInventory = await _repository.getInventoryByWarehouse(warehouseId);
    runInAction(() {
      inventoryItems
        ..clear()
        ..addAll(loadedInventory);
    });
  }

  Future<void> _reloadOutboundInventory() async {
    final warehouseId = outboundWarehouseId;
    if (warehouseId == null) {
      return;
    }

    final loadedInventory = await _repository.getInventoryByWarehouse(warehouseId);
    runInAction(() {
      outboundInventoryItems
        ..clear()
        ..addAll(loadedInventory);
    });
  }

  void _resetOutboundForm() {
    runInAction(() {
      _outboundProductId.value = null;
      _outboundQuantityInput.value = '';
      _outboundNote.value = '';
    });
  }

  void _setLoading(bool value) {
    runInAction(() {
      _isLoading.value = value;
    });
  }

  void _setSubmitting(bool value) {
    runInAction(() {
      _isSubmitting.value = value;
    });
  }

  void _setError(String message) {
    runInAction(() {
      _errorMessage.value = message;
    });
  }
}

