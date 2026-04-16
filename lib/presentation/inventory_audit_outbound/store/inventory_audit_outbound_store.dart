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
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/models/inventory_workflow_view_models.dart';

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
  int _outboundWarehouseRequestId = 0;
  int _sessionCounter = 1;

  @observable
  bool isLoading = false;

  @observable
  bool isSubmittingAudit = false;

  @observable
  bool isSubmittingOutbound = false;

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
  ObservableList<StocktakeSessionViewModel> stocktakeHistory =
      ObservableList<StocktakeSessionViewModel>();

  @observable
  ObservableList<OutboundIssueViewModel> outboundIssues =
      ObservableList<OutboundIssueViewModel>();

  @observable
  ObservableList<InventoryItem> outboundInventoryItems =
      ObservableList<InventoryItem>();

  @observable
  String? selectedWarehouseId;

  @observable
  String? selectedAuditProductId;

  @observable
  ObservableMap<String, String> physicalCountInputs =
      ObservableMap<String, String>();

  @observable
  String? outboundWarehouseId;

  @observable
  String? outboundProductId;

  @observable
  String outboundQuantityInput = '';

  @observable
  String outboundNote = '';

  @observable
  StocktakeSessionViewModel? activeSession;

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
  int get mismatchCount =>
      auditLines.where((line) => line.discrepancy != 0).length;

  @computed
  int get totalAbsoluteDiscrepancy =>
      auditLines.fold<int>(0, (sum, line) => sum + line.discrepancy.abs());

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
  bool get canOpenSession =>
      selectedWarehouseId != null &&
      inventoryItems.isNotEmpty &&
      !isSubmittingAudit &&
      (activeSession == null ||
          activeSession!.status == StocktakeSessionStatus.approved ||
          activeSession!.status == StocktakeSessionStatus.rejected);

  @computed
  bool get canSubmitCounts =>
      activeSession?.status == StocktakeSessionStatus.counting &&
      allCountsFilledAndValid &&
      !isSubmittingAudit;

  @computed
  bool get canCloseSession =>
      activeSession?.status == StocktakeSessionStatus.submitted &&
      activeSession?.closedAt == null &&
      !isSubmittingAudit;

  @computed
  bool get canReconcileSession =>
      activeSession?.status == StocktakeSessionStatus.submitted &&
      activeSession?.closedAt != null &&
      !isSubmittingAudit;

  @computed
  bool get canApproveSession =>
      activeSession?.status == StocktakeSessionStatus.reconciled &&
      !isSubmittingAudit;

  @computed
  bool get canRejectSession =>
      activeSession?.status == StocktakeSessionStatus.reconciled &&
      !isSubmittingAudit;

  @computed
  bool get canCreateOutboundIssue {
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
    return qty <= selectedItem.systemQty && !isSubmittingOutbound;
  }

  @computed
  String get openSessionDisabledReason {
    if (selectedWarehouseId == null) {
      return 'Choose warehouse first';
    }
    if (inventoryItems.isEmpty) {
      return 'No items to count';
    }
    if (activeSession != null &&
        activeSession!.status != StocktakeSessionStatus.approved &&
        activeSession!.status != StocktakeSessionStatus.rejected) {
      return 'Finish current session first';
    }
    if (isSubmittingAudit) {
      return 'Action in progress';
    }
    return '';
  }

  @computed
  String get submitCountsDisabledReason {
    if (activeSession?.status != StocktakeSessionStatus.counting) {
      return 'Session must be in counting status';
    }
    if (!allCountsFilledAndValid) {
      return 'All count lines must be valid';
    }
    if (isSubmittingAudit) {
      return 'Action in progress';
    }
    return '';
  }

  @computed
  String get closeSessionDisabledReason {
    if (activeSession?.status != StocktakeSessionStatus.submitted) {
      return 'Submit counts first';
    }
    if (activeSession?.closedAt != null) {
      return 'Session already closed';
    }
    if (isSubmittingAudit) {
      return 'Action in progress';
    }
    return '';
  }

  @computed
  String get reconcileSessionDisabledReason {
    if (activeSession?.status != StocktakeSessionStatus.submitted) {
      return 'Submit counts first';
    }
    if (activeSession?.closedAt == null) {
      return 'Close session before reconciling';
    }
    if (isSubmittingAudit) {
      return 'Action in progress';
    }
    return '';
  }

  @computed
  String get approveSessionDisabledReason {
    if (activeSession?.status != StocktakeSessionStatus.reconciled) {
      return 'Reconcile session first';
    }
    if (isSubmittingAudit) {
      return 'Action in progress';
    }
    return '';
  }

  @computed
  String get createOutboundDisabledReason {
    if (outboundWarehouseId == null) {
      return 'Choose warehouse first';
    }
    if (outboundProductId == null) {
      return 'Choose product first';
    }
    if (outboundQuantity == null || outboundQuantity! <= 0) {
      return 'Enter valid quantity';
    }
    if (selectedOutboundItem == null) {
      return 'Product unavailable in selected warehouse';
    }
    if (outboundQuantity! > selectedOutboundItem!.systemQty) {
      return 'Quantity exceeds available stock';
    }
    if (isSubmittingOutbound) {
      return 'Action in progress';
    }
    return '';
  }

  @action
  Future<void> loadInitialData() async {
    isLoading = true;
    clearError();

    try {
      final loadedWarehouses =
          await _getInventoryWarehousesUseCase.call(params: null);
      final loadedAuditRecords =
          await _getInventoryAuditRecordsUseCase.call(params: null);
      final loadedOutboundRecords =
          await _getInventoryOutboundRecordsUseCase.call(params: null);

      warehouses = ObservableList<InventoryWarehouse>.of(loadedWarehouses);
      auditRecords = ObservableList<AuditRecord>.of(loadedAuditRecords);
      outboundRecords = ObservableList<OutboundRecord>.of(loadedOutboundRecords);
      stocktakeHistory = ObservableList<StocktakeSessionViewModel>.of(
        loadedAuditRecords.map(_toStocktakeSession).toList(growable: false),
      );
      outboundIssues = ObservableList<OutboundIssueViewModel>.of(
        loadedOutboundRecords.map(_toOutboundIssue).toList(growable: false),
      );

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
    clearError();

    if (warehouseId == null) {
      return;
    }

    try {
      final loadedInventory =
          await _getInventoryByWarehouseUseCase.call(params: warehouseId);
      if (requestId != _selectedWarehouseRequestId ||
          selectedWarehouseId != warehouseId) {
        return;
      }

      runInAction(() {
        inventoryItems = ObservableList<InventoryItem>.of(loadedInventory);
        selectedAuditProductId =
            loadedInventory.isNotEmpty ? loadedInventory.first.productId : null;
      });
    } catch (error) {
      if (requestId != _selectedWarehouseRequestId ||
          selectedWarehouseId != warehouseId) {
        return;
      }
      runInAction(() {
        errorMessage = error.toString();
      });
    }
  }

  @action
  void setSelectedAuditProduct(String? productId) {
    selectedAuditProductId = productId;
  }

  @action
  void setPhysicalCount(String productId, String input) {
    physicalCountInputs[productId] = input;
  }

  String getPhysicalCountInput(String productId) =>
      physicalCountInputs[productId] ?? '';

  int getResolvedPhysicalCount(InventoryItem item) {
    final input = physicalCountInputs[item.productId];
    final parsed = int.tryParse(input ?? '');
    return parsed ?? item.systemQty;
  }

  @action
  Future<bool> openSession() async {
    if (!canOpenSession || selectedWarehouseId == null) {
      errorMessage = openSessionDisabledReason;
      return false;
    }

    clearError();
    final now = DateTime.now();
    final warehouseName = getWarehouseName(selectedWarehouseId);
    activeSession = StocktakeSessionViewModel(
      id: 'session-${_sessionCounter.toString().padLeft(3, '0')}',
      code: 'STK-${now.year}-${_sessionCounter.toString().padLeft(4, '0')}',
      warehouseId: selectedWarehouseId!,
      warehouseName: warehouseName,
      status: StocktakeSessionStatus.counting,
      openedAt: now,
      lines: inventoryItems
          .map(
            (item) => StocktakeLineViewModel(
              productId: item.productId,
              productName: item.productName,
              unit: item.unit,
              systemQty: item.systemQty,
            ),
          )
          .toList(growable: false),
      mismatchCount: 0,
      totalAbsoluteDiscrepancy: 0,
    );
    _sessionCounter++;
    return true;
  }

  @action
  Future<bool> submitCounts() async {
    final session = activeSession;
    if (!canSubmitCounts || session == null) {
      errorMessage = submitCountsDisabledReason;
      return false;
    }

    isSubmittingAudit = true;
    clearError();

    try {
      final lines = auditLines
          .map(
            (line) => StocktakeLineViewModel(
              productId: line.productId,
              productName: line.productName,
              unit: line.unit,
              systemQty: line.systemQty,
              countedQty: line.physicalQty,
            ),
          )
          .toList(growable: false);

      final mismatch = lines
          .where((line) => (line.discrepancy ?? 0) != 0)
          .length;
      final totalAbs = lines.fold<int>(
        0,
        (sum, line) => sum + (line.discrepancy ?? 0).abs(),
      );

      activeSession = session.copyWith(
        status: StocktakeSessionStatus.submitted,
        lines: lines,
        mismatchCount: mismatch,
        totalAbsoluteDiscrepancy: totalAbs,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmittingAudit = false;
    }
  }

  @action
  Future<bool> closeSession() async {
    final session = activeSession;
    if (!canCloseSession || session == null) {
      errorMessage = closeSessionDisabledReason;
      return false;
    }

    activeSession = session.copyWith(closedAt: DateTime.now());
    return true;
  }

  @action
  Future<bool> reconcileSession() async {
    final session = activeSession;
    if (!canReconcileSession || session == null || selectedWarehouseId == null) {
      errorMessage = reconcileSessionDisabledReason;
      return false;
    }

    isSubmittingAudit = true;
    clearError();

    try {
      final record = await _saveInventoryAuditSessionUseCase.call(
        params: SaveInventoryAuditSessionParams(
          warehouseId: selectedWarehouseId!,
          lines: session.lines
              .map(
                (line) => AuditLine(
                  productId: line.productId,
                  productName: line.productName,
                  systemQty: line.systemQty,
                  physicalQty: line.countedQty ?? line.systemQty,
                  discrepancy: (line.countedQty ?? line.systemQty) - line.systemQty,
                  unit: line.unit,
                ),
              )
              .toList(growable: false),
        ),
      );

      auditRecords.insert(0, record);
      await _reloadInventoryForSelectedWarehouse();

      final reconciled = session.copyWith(
        status: StocktakeSessionStatus.reconciled,
        reconciledAt: DateTime.now(),
        serverCalculated: true,
      );
      activeSession = reconciled;
      _upsertSessionHistory(reconciled);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmittingAudit = false;
    }
  }

  @action
  Future<bool> approveSession() async {
    final session = activeSession;
    if (!canApproveSession || session == null) {
      errorMessage = approveSessionDisabledReason;
      return false;
    }

    isSubmittingAudit = true;
    clearError();

    try {
      final approved = session.copyWith(
        status: StocktakeSessionStatus.approved,
        approvedAt: DateTime.now(),
        approverName: 'Mock Approver',
      );
      activeSession = approved;
      _upsertSessionHistory(approved);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmittingAudit = false;
    }
  }

  @action
  Future<bool> rejectSession() async {
    final session = activeSession;
    if (!canRejectSession || session == null) {
      errorMessage = approveSessionDisabledReason;
      return false;
    }

    activeSession = session.copyWith(
      status: StocktakeSessionStatus.rejected,
      approvedAt: DateTime.now(),
      approverName: 'Mock Reviewer',
    );
    _upsertSessionHistory(activeSession!);
    return true;
  }

  @action
  Future<void> setOutboundWarehouse(String? warehouseId) async {
    final requestId = ++_outboundWarehouseRequestId;
    outboundWarehouseId = warehouseId;
    outboundProductId = null;
    outboundQuantityInput = '';
    outboundNote = '';
    outboundInventoryItems = ObservableList<InventoryItem>();
    clearError();

    if (warehouseId != null &&
        warehouseId == selectedWarehouseId &&
        inventoryItems.isNotEmpty) {
      outboundInventoryItems = ObservableList<InventoryItem>.of(
        inventoryItems.where((item) => item.warehouseId == warehouseId),
      );
    }

    if (warehouseId == null) {
      return;
    }

    try {
      final loadedInventory =
          await _getInventoryByWarehouseUseCase.call(params: warehouseId);
      if (requestId != _outboundWarehouseRequestId ||
          outboundWarehouseId != warehouseId) {
        return;
      }
      runInAction(() {
        outboundInventoryItems = ObservableList<InventoryItem>.of(loadedInventory);
      });
    } catch (error) {
      if (requestId != _outboundWarehouseRequestId ||
          outboundWarehouseId != warehouseId) {
        return;
      }
      runInAction(() {
        errorMessage = error.toString();
      });
    }
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
  Future<bool> createOutboundIssue() async {
    if (!canCreateOutboundIssue) {
      errorMessage = createOutboundDisabledReason;
      return false;
    }

    isSubmittingOutbound = true;
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

      final issue = _toOutboundIssue(record);
      outboundIssues.insert(0, issue);

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
      isSubmittingOutbound = false;
    }
  }

  @action
  void cancelOutboundIssue(String outboundId) {
    final index = outboundIssues.indexWhere((issue) => issue.id == outboundId);
    if (index < 0) {
      return;
    }
    final existing = outboundIssues[index];
    outboundIssues[index] = existing.copyWith(
      status: OutboundIssueStatus.cancelled,
      updatedAt: DateTime.now(),
    );
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

  @action
  void _upsertSessionHistory(StocktakeSessionViewModel session) {
    final index = stocktakeHistory.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      stocktakeHistory[index] = session;
      return;
    }
    stocktakeHistory.insert(0, session);
  }

  StocktakeSessionViewModel _toStocktakeSession(AuditRecord record) {
    return StocktakeSessionViewModel(
      id: record.id,
      code: record.sessionCode ?? record.id.toUpperCase(),
      warehouseId: record.warehouseId,
      warehouseName: record.warehouseName,
      status: _parseStocktakeStatus(record.status),
      openedAt: record.createdAt,
      closedAt: record.closedAt,
      reconciledAt: record.reconciledAt,
      approvedAt: record.approvedAt,
      approverName: record.approverName,
      lines: record.lines
          .map(
            (line) => StocktakeLineViewModel(
              productId: line.productId,
              productName: line.productName,
              unit: line.unit,
              systemQty: line.systemQty,
              countedQty: line.physicalQty,
            ),
          )
          .toList(growable: false),
      mismatchCount: record.totalMismatchCount,
      totalAbsoluteDiscrepancy: record.lines.fold<int>(
        0,
        (sum, line) => sum + line.discrepancy.abs(),
      ),
      serverCalculated: true,
    );
  }

  OutboundIssueViewModel _toOutboundIssue(OutboundRecord record) {
    final now = record.updatedAt ?? record.createdAt;
    return OutboundIssueViewModel(
      id: record.id,
      code: record.code ?? record.id.toUpperCase(),
      warehouseId: record.warehouseId,
      warehouseName: record.warehouseName,
      productId: record.productId,
      productName: record.productName,
      quantity: record.quantity,
      status: _parseOutboundStatus(record.status),
      createdAt: record.createdAt,
      updatedAt: now,
      note: record.note,
    );
  }

  StocktakeSessionStatus _parseStocktakeStatus(String raw) {
    switch (raw) {
      case 'draft':
        return StocktakeSessionStatus.draft;
      case 'counting':
        return StocktakeSessionStatus.counting;
      case 'submitted':
        return StocktakeSessionStatus.submitted;
      case 'approved':
        return StocktakeSessionStatus.approved;
      case 'rejected':
        return StocktakeSessionStatus.rejected;
      case 'reconciled':
      default:
        return StocktakeSessionStatus.reconciled;
    }
  }

  OutboundIssueStatus _parseOutboundStatus(String raw) {
    switch (raw) {
      case 'draft':
        return OutboundIssueStatus.draft;
      case 'cancelled':
        return OutboundIssueStatus.cancelled;
      case 'confirmed':
      default:
        return OutboundIssueStatus.confirmed;
    }
  }
}
