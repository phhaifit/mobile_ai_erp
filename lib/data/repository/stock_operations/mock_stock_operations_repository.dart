import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';

class MockStockOperationsRepository extends StockOperationsRepository {
  final List<Warehouse> _warehouses = const [
    Warehouse(id: 'wh-01', name: 'Main Warehouse', location: 'Campus A'),
    Warehouse(id: 'wh-02', name: 'North Warehouse', location: 'District 7'),
    Warehouse(id: 'wh-03', name: 'Outlet Warehouse', location: 'Thu Duc'),
  ];

  List<ProductStock> _stocks = const [
    ProductStock(
      id: 's-1',
      productId: 'p-01',
      productName: 'A4 Paper Box',
      warehouseId: 'wh-01',
      availableQuantity: 120,
    ),
    ProductStock(
      id: 's-2',
      productId: 'p-02',
      productName: 'Ink Cartridge',
      warehouseId: 'wh-01',
      availableQuantity: 40,
    ),
    ProductStock(
      id: 's-3',
      productId: 'p-01',
      productName: 'A4 Paper Box',
      warehouseId: 'wh-02',
      availableQuantity: 90,
    ),
    ProductStock(
      id: 's-4',
      productId: 'p-03',
      productName: 'Label Roll',
      warehouseId: 'wh-02',
      availableQuantity: 75,
    ),
    ProductStock(
      id: 's-5',
      productId: 'p-02',
      productName: 'Ink Cartridge',
      warehouseId: 'wh-03',
      availableQuantity: 15,
    ),
  ];

  final List<StockOperation> _operations = [
    StockOperation(
      id: 'op-001',
      type: StockOperationType.transfer,
      status: StockOperationStatus.completed,
      productId: 'p-01',
      productName: 'A4 Paper Box',
      quantity: 10,
      sourceWarehouseId: 'wh-01',
      sourceWarehouseName: 'Main Warehouse',
      destinationWarehouseId: 'wh-02',
      destinationWarehouseName: 'North Warehouse',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      note: 'Routine balancing',
    ),
    StockOperation(
      id: 'op-002',
      type: StockOperationType.damaged,
      status: StockOperationStatus.completed,
      productId: 'p-02',
      productName: 'Ink Cartridge',
      quantity: 2,
      sourceWarehouseId: 'wh-03',
      sourceWarehouseName: 'Outlet Warehouse',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      note: 'Damaged package',
    ),
  ];

  int _idCounter = 3;

  @override
  Future<List<Warehouse>> getWarehouses() async {
    return List<Warehouse>.unmodifiable(_warehouses);
  }

  @override
  Future<List<ProductStock>> getProductStocks() async {
    return List<ProductStock>.unmodifiable(_stocks);
  }

  @override
  Future<List<StockOperation>> getOperations() async {
    final sorted = List<StockOperation>.from(_operations)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<StockOperation>.unmodifiable(sorted);
  }

  @override
  Future<StockOperation> submitTransfer({
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String productId,
    required int quantity,
  }) async {
    final sourceWarehouse = _findWarehouse(sourceWarehouseId);
    final destinationWarehouse = _findWarehouse(destinationWarehouseId);
    final sourceStock = _findStock(sourceWarehouseId, productId);

    if (sourceStock == null || sourceStock.availableQuantity < quantity) {
      throw Exception('Insufficient stock for transfer.');
    }

    final destinationStock = _findStock(destinationWarehouseId, productId);

    _updateStock(
      warehouseId: sourceWarehouseId,
      productId: productId,
      quantityDelta: -quantity,
      fallbackName: sourceStock.productName,
    );

    _updateStock(
      warehouseId: destinationWarehouseId,
      productId: productId,
      quantityDelta: quantity,
      fallbackName: sourceStock.productName,
    );

    final operation = StockOperation(
      id: 'op-${_idCounter.toString().padLeft(3, '0')}',
      type: StockOperationType.transfer,
      status: StockOperationStatus.completed,
      productId: productId,
      productName: destinationStock?.productName ?? sourceStock.productName,
      quantity: quantity,
      sourceWarehouseId: sourceWarehouseId,
      sourceWarehouseName: sourceWarehouse.name,
      destinationWarehouseId: destinationWarehouseId,
      destinationWarehouseName: destinationWarehouse.name,
      createdAt: DateTime.now(),
      note: 'Internal transfer',
    );

    _idCounter++;
    _operations.add(operation);
    return operation;
  }

  @override
  Future<StockOperation> submitDamagedOrExpired({
    required String warehouseId,
    required String productId,
    required int quantity,
    required StockOperationType type,
    String? note,
  }) async {
    if (type != StockOperationType.damaged &&
        type != StockOperationType.expired) {
      throw Exception('Invalid operation type for damaged/expired.');
    }

    final warehouse = _findWarehouse(warehouseId);
    final stock = _findStock(warehouseId, productId);

    if (stock == null || stock.availableQuantity < quantity) {
      throw Exception('Insufficient stock for this operation.');
    }

    _updateStock(
      warehouseId: warehouseId,
      productId: productId,
      quantityDelta: -quantity,
      fallbackName: stock.productName,
    );

    final operation = StockOperation(
      id: 'op-${_idCounter.toString().padLeft(3, '0')}',
      type: type,
      status: StockOperationStatus.completed,
      productId: productId,
      productName: stock.productName,
      quantity: quantity,
      sourceWarehouseId: warehouseId,
      sourceWarehouseName: warehouse.name,
      createdAt: DateTime.now(),
      note: note,
    );

    _idCounter++;
    _operations.add(operation);
    return operation;
  }

  Warehouse _findWarehouse(String warehouseId) {
    return _warehouses.firstWhere(
      (warehouse) => warehouse.id == warehouseId,
      orElse: () => throw Exception('Warehouse not found.'),
    );
  }

  ProductStock? _findStock(String warehouseId, String productId) {
    try {
      return _stocks.firstWhere(
        (stock) =>
            stock.warehouseId == warehouseId && stock.productId == productId,
      );
    } catch (_) {
      return null;
    }
  }

  void _updateStock({
    required String warehouseId,
    required String productId,
    required int quantityDelta,
    required String fallbackName,
  }) {
    final current = _findStock(warehouseId, productId);

    if (current == null) {
      _stocks = [
        ..._stocks,
        ProductStock(
          id: 's-${_stocks.length + 1}',
          productId: productId,
          productName: fallbackName,
          warehouseId: warehouseId,
          availableQuantity: quantityDelta,
        ),
      ];
      return;
    }

    _stocks = _stocks
        .map(
          (stock) => stock.id == current.id
              ? stock.copyWith(
                  availableQuantity: stock.availableQuantity + quantityDelta,
                )
              : stock,
        )
        .where((stock) => stock.availableQuantity > 0)
        .toList();
  }
}
