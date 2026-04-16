import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';

part 'stock_operations_store.g.dart';

enum StockOperationsView { dashboard, transfer, damagedGoods, history }

enum StockOperationHistoryFilter { all, transfer, damaged, expired }

class StockDashboardAction {
  const StockDashboardAction({
    required this.view,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final StockOperationsView view;
  final String title;
  final String subtitle;
  final IconData icon;
}

class StockOperationsStore = _StockOperationsStore with _$StockOperationsStore;

abstract class _StockOperationsStore with Store {
  _StockOperationsStore(this._repository);

  final StockOperationsRepository _repository;

  @observable
  ObservableList<Warehouse> warehouses = ObservableList<Warehouse>();

  @observable
  ObservableList<ProductStock> productStocks = ObservableList<ProductStock>();

  @observable
  ObservableList<StockOperation> operations = ObservableList<StockOperation>();

  @observable
  bool isLoading = false;

  @observable
  bool isSubmitting = false;

  @observable
  String errorMessage = '';

  @observable
  StockOperationsView currentView = StockOperationsView.dashboard;

  @observable
  StockOperationHistoryFilter historyFilter = StockOperationHistoryFilter.all;

  @observable
  String? transferSourceWarehouseId;

  @observable
  String? transferDestinationWarehouseId;

  @observable
  String? transferProductId;

  @observable
  String transferQuantityInput = '';

  @observable
  String? disposalWarehouseId;

  @observable
  String? disposalProductId;

  @observable
  String disposalQuantityInput = '';

  @observable
  StockOperationType disposalType = StockOperationType.damaged;

  @observable
  String disposalNote = '';

  @computed
  int? get transferQuantity => int.tryParse(transferQuantityInput);

  @computed
  int? get disposalQuantity => int.tryParse(disposalQuantityInput);

  @computed
  List<StockDashboardAction> get dashboardActions => const [
    StockDashboardAction(
      view: StockOperationsView.transfer,
      title: 'Transfer',
      subtitle: 'Move stock between warehouses',
      icon: Icons.swap_horiz,
    ),
    StockDashboardAction(
      view: StockOperationsView.damagedGoods,
      title: 'Damaged / Expired',
      subtitle: 'Record stock loss operation',
      icon: Icons.report_problem,
    ),
    StockDashboardAction(
      view: StockOperationsView.history,
      title: 'History',
      subtitle: 'Review all local operations',
      icon: Icons.history,
    ),
  ];

  @computed
  List<ProductStock> get availableTransferProducts {
    if (transferSourceWarehouseId == null) {
      return const [];
    }
    return getProductsByWarehouse(transferSourceWarehouseId);
  }

  @computed
  ProductStock? get selectedTransferStock {
    final productId = transferProductId;
    if (productId == null || transferSourceWarehouseId == null) {
      return null;
    }

    for (final stock in productStocks) {
      if (stock.productId == productId &&
          stock.warehouseId == transferSourceWarehouseId) {
        return stock;
      }
    }
    return null;
  }

  @computed
  bool get canCreateTransferDraft {
    final source = transferSourceWarehouseId;
    final destination = transferDestinationWarehouseId;
    final productId = transferProductId;
    final quantity = transferQuantity;
    final stock = selectedTransferStock;

    if (source == null ||
        destination == null ||
        productId == null ||
        quantity == null) {
      return false;
    }

    if (quantity <= 0 || source == destination || stock == null) {
      return false;
    }

    return quantity <= stock.availableQuantity;
  }

  @computed
  bool get canSubmitDamagedOrExpired {
    final warehouseId = disposalWarehouseId;
    final productId = disposalProductId;
    final quantity = disposalQuantity;

    if (warehouseId == null ||
        productId == null ||
        quantity == null ||
        quantity <= 0) {
      return false;
    }

    final stocks = getProductsByWarehouse(warehouseId);
    ProductStock? target;
    for (final stock in stocks) {
      if (stock.productId == productId) {
        target = stock;
        break;
      }
    }

    if (target == null) {
      return false;
    }

    return quantity <= target.availableQuantity;
  }

  @computed
  int get totalOperationsCount => operations.length;

  @computed
  int get damagedOperationsCount => operations
      .where((operation) => operation.type == StockOperationType.damaged)
      .length;

  @computed
  int get expiredOperationsCount => operations
      .where((operation) => operation.type == StockOperationType.expired)
      .length;

  @computed
  List<StockOperation> get filteredOperations {
    switch (historyFilter) {
      case StockOperationHistoryFilter.all:
        return operations.toList(growable: false);
      case StockOperationHistoryFilter.transfer:
        return operations
            .where((op) => op.type == StockOperationType.transfer)
            .toList(growable: false);
      case StockOperationHistoryFilter.damaged:
        return operations
            .where((op) => op.type == StockOperationType.damaged)
            .toList(growable: false);
      case StockOperationHistoryFilter.expired:
        return operations
            .where((op) => op.type == StockOperationType.expired)
            .toList(growable: false);
    }
  }

  @action
  Future<void> loadInitialData() async {
    isLoading = true;
    clearError();

    try {
      final loadedWarehouses = await _repository.getWarehouses();
      final loadedStocks = await _repository.getProductStocks();
      final loadedOperations = await _repository.getOperations();

      warehouses = ObservableList<Warehouse>.of(loadedWarehouses);
      productStocks = ObservableList<ProductStock>.of(loadedStocks);
      operations = ObservableList<StockOperation>.of(loadedOperations);

      if (loadedWarehouses.isNotEmpty) {
        transferSourceWarehouseId = loadedWarehouses.first.id;
        disposalWarehouseId = loadedWarehouses.first.id;
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setCurrentView(StockOperationsView view) {
    currentView = view;
  }

  @action
  void setHistoryFilter(StockOperationHistoryFilter filter) {
    historyFilter = filter;
  }

  @action
  void setTransferSourceWarehouse(String? warehouseId) {
    transferSourceWarehouseId = warehouseId;
    transferDestinationWarehouseId = null;
    transferProductId = null;
  }

  @action
  void setTransferDestinationWarehouse(String? warehouseId) {
    transferDestinationWarehouseId = warehouseId;
  }

  @action
  void setTransferProduct(String? productId) {
    transferProductId = productId;
  }

  @action
  void setTransferQuantity(String value) {
    transferQuantityInput = value;
  }

  @action
  void setDisposalWarehouse(String? warehouseId) {
    disposalWarehouseId = warehouseId;
    disposalProductId = null;
  }

  @action
  void setDisposalProduct(String? productId) {
    disposalProductId = productId;
  }

  @action
  void setDisposalQuantity(String value) {
    disposalQuantityInput = value;
  }

  @action
  void setDisposalType(StockOperationType type) {
    disposalType = type;
  }

  @action
  void setDisposalNote(String note) {
    disposalNote = note;
  }

  @action
  Future<bool> createTransferDraft() async {
    if (!canCreateTransferDraft) {
      errorMessage = 'Please complete transfer fields with valid values.';
      return false;
    }

    isSubmitting = true;
    clearError();

    try {
      await _repository.createTransfer(
        sourceWarehouseId: transferSourceWarehouseId!,
        destinationWarehouseId: transferDestinationWarehouseId!,
        productId: transferProductId!,
        quantity: transferQuantity!,
      );
      await _reloadOperationalData();
      _resetTransferForm();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  @action
  Future<bool> approveSelectedTransfer(String transferId) async {
    isSubmitting = true;
    clearError();
    try {
      await _repository.approveTransfer(transferId: transferId);
      await _reloadOperationalData();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  @action
  Future<bool> completeSelectedTransfer(String transferId) async {
    isSubmitting = true;
    clearError();
    try {
      await _repository.completeTransfer(transferId: transferId);
      await _reloadOperationalData();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  @action
  Future<bool> submitDamagedOrExpired() async {
    if (!canSubmitDamagedOrExpired) {
      errorMessage =
          'Please complete damaged/expired fields with valid values.';
      return false;
    }

    isSubmitting = true;
    clearError();

    try {
      await _repository.submitDamagedOrExpired(
        warehouseId: disposalWarehouseId!,
        productId: disposalProductId!,
        quantity: disposalQuantity!,
        type: disposalType,
        note: disposalNote.isEmpty ? null : disposalNote,
      );
      await _reloadOperationalData();
      _resetDisposalForm();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  @action
  void clearError() {
    errorMessage = '';
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

  List<ProductStock> getProductsByWarehouse(String? warehouseId) {
    if (warehouseId == null) {
      return const [];
    }

    return productStocks
        .where((stock) => stock.warehouseId == warehouseId)
        .toList(growable: false);
  }

  Future<void> _reloadOperationalData() async {
    final loadedStocks = await _repository.getProductStocks();
    final loadedOperations = await _repository.getOperations();

    productStocks = ObservableList<ProductStock>.of(loadedStocks);
    operations = ObservableList<StockOperation>.of(loadedOperations);
  }

  @action
  void _resetTransferForm() {
    transferDestinationWarehouseId = null;
    transferProductId = null;
    transferQuantityInput = '';
  }

  @action
  void _resetDisposalForm() {
    disposalProductId = null;
    disposalQuantityInput = '';
    disposalNote = '';
    disposalType = StockOperationType.damaged;
  }
}
