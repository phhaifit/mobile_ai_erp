import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/stock_operations/mock_stock_operations_repository.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';

void main() {
  late StockOperationsStore store;

  setUp(() async {
    store = StockOperationsStore(MockStockOperationsRepository());
    await store.loadInitialData();
  });

  test('transfer validation rejects same warehouse and invalid quantity', () {
    final source = store.warehouses.first.id;
    store.setTransferSourceWarehouse(source);
    store.setTransferDestinationWarehouse(source);
    store.setTransferProduct(store.availableTransferProducts.first.productId);
    store.setTransferQuantity('0');

    expect(store.canSubmitTransfer, isFalse);
  });

  test(
    'successful transfer appends operation and updates stock projection',
    () async {
      final source = 'wh-01';
      final destination = 'wh-02';
      final productId = 'p-01';

      final beforeSource = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == source && s.productId == productId,
          )
          .availableQuantity;
      final beforeDestination = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == destination && s.productId == productId,
          )
          .availableQuantity;

      store.setTransferSourceWarehouse(source);
      store.setTransferDestinationWarehouse(destination);
      store.setTransferProduct(productId);
      store.setTransferQuantity('5');

      final success = await store.submitTransfer();

      final afterSource = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == source && s.productId == productId,
          )
          .availableQuantity;
      final afterDestination = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == destination && s.productId == productId,
          )
          .availableQuantity;

      expect(success, isTrue);
      expect(afterSource, beforeSource - 5);
      expect(afterDestination, beforeDestination + 5);
      expect(store.operations.first.type, StockOperationType.transfer);
    },
  );

  test('damaged/expired submit appends matching operation type', () async {
    store.setDisposalWarehouse('wh-01');
    store.setDisposalProduct('p-02');
    store.setDisposalType(StockOperationType.expired);
    store.setDisposalQuantity('2');

    final success = await store.submitDamagedOrExpired();

    expect(success, isTrue);
    expect(store.operations.first.type, StockOperationType.expired);
  });

  test('history timeline keeps mixed operation types', () async {
    store.setTransferSourceWarehouse('wh-01');
    store.setTransferDestinationWarehouse('wh-02');
    store.setTransferProduct('p-01');
    store.setTransferQuantity('3');
    await store.submitTransfer();

    store.setDisposalWarehouse('wh-01');
    store.setDisposalProduct('p-02');
    store.setDisposalType(StockOperationType.damaged);
    store.setDisposalQuantity('1');
    await store.submitDamagedOrExpired();

    final types = store.filteredOperations.map((e) => e.type).toSet();
    expect(types.contains(StockOperationType.transfer), isTrue);
    expect(types.contains(StockOperationType.damaged), isTrue);
  });
}
