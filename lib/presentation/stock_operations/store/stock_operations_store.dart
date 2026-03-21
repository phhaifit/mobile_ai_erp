import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';
import 'package:mobx/mobx.dart';

enum StockOperationsView { dashboard, transfer, damagedGoods, history }

class StockOperationsStore {
  StockOperationsStore(this._repository)
    : _availableTransferProducts = Computed<List<ProductStock>>(() => const []),
      _selectedTransferStock = Computed<ProductStock?>(() => null),
      _transferSubmitEnabled = Computed<bool>(() => false),
      _damagedSubmitEnabled = Computed<bool>(() => false),
      _totalOperationsCount = Computed<int>(() => 0),
      _damagedOperationsCount = Computed<int>(() => 0),
      _expiredOperationsCount = Computed<int>(() => 0) {
    _availableTransferProducts = Computed<List<ProductStock>>(
      _computeAvailableTransferProducts,
    );
    _selectedTransferStock = Computed<ProductStock?>(
      _computeSelectedTransferStock,
    );
    _transferSubmitEnabled = Computed<bool>(_computeTransferSubmitEnabled);
    _damagedSubmitEnabled = Computed<bool>(_computeDamagedSubmitEnabled);
    _totalOperationsCount = Computed<int>(() => operations.length);
    _damagedOperationsCount = Computed<int>(
      () => operations
          .where((operation) => operation.type == StockOperationType.damaged)
          .length,
    );
    _expiredOperationsCount = Computed<int>(
      () => operations
          .where((operation) => operation.type == StockOperationType.expired)
          .length,
    );
  }

  final StockOperationsRepository _repository;

  final ObservableList<Warehouse> warehouses = ObservableList<Warehouse>();
  final ObservableList<ProductStock> productStocks =
      ObservableList<ProductStock>();
  final ObservableList<StockOperation> operations =
      ObservableList<StockOperation>();

  final Observable<bool> _isLoading = Observable(false);
  final Observable<bool> _isSubmitting = Observable(false);
  final Observable<String> _errorMessage = Observable('');
  final Observable<StockOperationsView> _currentView = Observable(
    StockOperationsView.dashboard,
  );

  final Observable<String?> _transferSourceWarehouseId = Observable(null);
  final Observable<String?> _transferDestinationWarehouseId = Observable(null);
  final Observable<String?> _transferProductId = Observable(null);
  final Observable<String> _transferQuantityInput = Observable('');

  final Observable<String?> _disposalWarehouseId = Observable(null);
  final Observable<String?> _disposalProductId = Observable(null);
  final Observable<String> _disposalQuantityInput = Observable('');
  final Observable<StockOperationType> _disposalType = Observable(
    StockOperationType.damaged,
  );
  final Observable<String> _disposalNote = Observable('');

  late Computed<List<ProductStock>> _availableTransferProducts;
  late Computed<ProductStock?> _selectedTransferStock;
  late Computed<bool> _transferSubmitEnabled;
  late Computed<bool> _damagedSubmitEnabled;
  late Computed<int> _totalOperationsCount;
  late Computed<int> _damagedOperationsCount;
  late Computed<int> _expiredOperationsCount;

  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  String get errorMessage => _errorMessage.value;
  StockOperationsView get currentView => _currentView.value;

  String? get transferSourceWarehouseId => _transferSourceWarehouseId.value;
  String? get transferDestinationWarehouseId =>
      _transferDestinationWarehouseId.value;
  String? get transferProductId => _transferProductId.value;
  String get transferQuantityInput => _transferQuantityInput.value;

  String? get disposalWarehouseId => _disposalWarehouseId.value;
  String? get disposalProductId => _disposalProductId.value;
  String get disposalQuantityInput => _disposalQuantityInput.value;
  StockOperationType get disposalType => _disposalType.value;
  String get disposalNote => _disposalNote.value;

  List<ProductStock> get availableTransferProducts =>
      _availableTransferProducts.value;
  ProductStock? get selectedTransferStock => _selectedTransferStock.value;
  bool get canSubmitTransfer => _transferSubmitEnabled.value;
  bool get canSubmitDamagedOrExpired => _damagedSubmitEnabled.value;
  int get totalOperationsCount => _totalOperationsCount.value;
  int get damagedOperationsCount => _damagedOperationsCount.value;
  int get expiredOperationsCount => _expiredOperationsCount.value;

  int? get transferQuantity => int.tryParse(_transferQuantityInput.value);
  int? get disposalQuantity => int.tryParse(_disposalQuantityInput.value);

  Future<void> loadInitialData() async {
    _setLoading(true);
    clearError();

    try {
      final loadedWarehouses = await _repository.getWarehouses();
      final loadedStocks = await _repository.getProductStocks();
      final loadedOperations = await _repository.getOperations();

      runInAction(() {
        warehouses
          ..clear()
          ..addAll(loadedWarehouses);

        productStocks
          ..clear()
          ..addAll(loadedStocks);

        operations
          ..clear()
          ..addAll(loadedOperations);

        if (loadedWarehouses.isNotEmpty) {
          _transferSourceWarehouseId.value = loadedWarehouses.first.id;
          _disposalWarehouseId.value = loadedWarehouses.first.id;
        }
      });
    } catch (error) {
      _setError(error.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setCurrentView(StockOperationsView view) {
    runInAction(() {
      _currentView.value = view;
    });
  }

  void setTransferSourceWarehouse(String? warehouseId) {
    runInAction(() {
      _transferSourceWarehouseId.value = warehouseId;
      _transferProductId.value = null;
    });
  }

  void setTransferDestinationWarehouse(String? warehouseId) {
    runInAction(() {
      _transferDestinationWarehouseId.value = warehouseId;
    });
  }

  void setTransferProduct(String? productId) {
    runInAction(() {
      _transferProductId.value = productId;
    });
  }

  void setTransferQuantity(String value) {
    runInAction(() {
      _transferQuantityInput.value = value;
    });
  }

  void setDisposalWarehouse(String? warehouseId) {
    runInAction(() {
      _disposalWarehouseId.value = warehouseId;
      _disposalProductId.value = null;
    });
  }

  void setDisposalProduct(String? productId) {
    runInAction(() {
      _disposalProductId.value = productId;
    });
  }

  void setDisposalQuantity(String value) {
    runInAction(() {
      _disposalQuantityInput.value = value;
    });
  }

  void setDisposalType(StockOperationType type) {
    runInAction(() {
      _disposalType.value = type;
    });
  }

  void setDisposalNote(String note) {
    runInAction(() {
      _disposalNote.value = note;
    });
  }

  Future<bool> submitTransfer() async {
    if (!canSubmitTransfer) {
      _setError('Please complete transfer fields with valid values.');
      return false;
    }

    _setSubmitting(true);
    clearError();

    try {
      await _repository.submitTransfer(
        sourceWarehouseId: transferSourceWarehouseId!,
        destinationWarehouseId: transferDestinationWarehouseId!,
        productId: transferProductId!,
        quantity: transferQuantity!,
      );
      await _reloadOperationalData();
      _resetTransferForm();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> submitDamagedOrExpired() async {
    if (!canSubmitDamagedOrExpired) {
      _setError('Please complete damaged/expired fields with valid values.');
      return false;
    }

    _setSubmitting(true);
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
      _setError(error.toString());
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void clearError() {
    runInAction(() {
      _errorMessage.value = '';
    });
  }

  String getWarehouseName(String? warehouseId) {
    if (warehouseId == null) {
      return '-';
    }
    return warehouses
        .firstWhere(
          (warehouse) => warehouse.id == warehouseId,
          orElse: () => const Warehouse(id: '', name: '-', location: ''),
        )
        .name;
  }

  List<ProductStock> getProductsByWarehouse(String? warehouseId) {
    if (warehouseId == null) {
      return const [];
    }

    return productStocks
        .where((stock) => stock.warehouseId == warehouseId)
        .toList(growable: false);
  }

  List<StockOperation> get filteredOperations =>
      operations.toList(growable: false);

  List<ProductStock> _computeAvailableTransferProducts() {
    if (transferSourceWarehouseId == null) {
      return const [];
    }
    return getProductsByWarehouse(transferSourceWarehouseId);
  }

  ProductStock? _computeSelectedTransferStock() {
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

  bool _computeTransferSubmitEnabled() {
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

  bool _computeDamagedSubmitEnabled() {
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

  Future<void> _reloadOperationalData() async {
    final loadedStocks = await _repository.getProductStocks();
    final loadedOperations = await _repository.getOperations();

    runInAction(() {
      productStocks
        ..clear()
        ..addAll(loadedStocks);
      operations
        ..clear()
        ..addAll(loadedOperations);
    });
  }

  void _resetTransferForm() {
    runInAction(() {
      _transferDestinationWarehouseId.value = null;
      _transferProductId.value = null;
      _transferQuantityInput.value = '';
    });
  }

  void _resetDisposalForm() {
    runInAction(() {
      _disposalProductId.value = null;
      _disposalQuantityInput.value = '';
      _disposalNote.value = '';
      _disposalType.value = StockOperationType.damaged;
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

