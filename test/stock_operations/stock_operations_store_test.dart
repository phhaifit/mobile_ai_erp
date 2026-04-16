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

    expect(store.canCreateTransferDraft, isFalse);
  });

  test(
    'create transfer draft does not move stock and creates draft status',
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

      final success = await store.createTransferDraft();

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
      expect(afterSource, beforeSource);
      expect(afterDestination, beforeDestination);
      expect(store.operations.first.type, StockOperationType.transfer);
      expect(store.operations.first.status, StockOperationStatus.draft);
    },
  );

  test(
    'approve transfer changes status only, complete moves stock and marks completed',
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
      store.setTransferQuantity('4');
      await store.createTransferDraft();

      final transferId = store.operations.first.id;
      final approved = await store.approveSelectedTransfer(transferId);
      expect(approved, isTrue);
      expect(store.operations.first.status, StockOperationStatus.approved);

      final afterApproveSource = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == source && s.productId == productId,
          )
          .availableQuantity;
      final afterApproveDestination = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == destination && s.productId == productId,
          )
          .availableQuantity;
      expect(afterApproveSource, beforeSource);
      expect(afterApproveDestination, beforeDestination);

      final completed = await store.completeSelectedTransfer(transferId);
      expect(completed, isTrue);
      expect(store.operations.first.status, StockOperationStatus.completed);

      final afterCompleteSource = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == source && s.productId == productId,
          )
          .availableQuantity;
      final afterCompleteDestination = store.productStocks
          .firstWhere(
            (s) => s.warehouseId == destination && s.productId == productId,
          )
          .availableQuantity;
      expect(afterCompleteSource, beforeSource - 4);
      expect(afterCompleteDestination, beforeDestination + 4);
    },
  );

  test(
    'invalid transfer transition fails when completing draft directly',
    () async {
      store.setTransferSourceWarehouse('wh-01');
      store.setTransferDestinationWarehouse('wh-02');
      store.setTransferProduct('p-01');
      store.setTransferQuantity('2');
      await store.createTransferDraft();

      final transferId = store.operations.first.id;
      final success = await store.completeSelectedTransfer(transferId);

      expect(success, isFalse);
      expect(store.operations.first.status, StockOperationStatus.draft);
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

  test('history filter returns only selected operation type', () async {
    store.setTransferSourceWarehouse('wh-01');
    store.setTransferDestinationWarehouse('wh-02');
    store.setTransferProduct('p-01');
    store.setTransferQuantity('2');
    await store.createTransferDraft();
    final transferId = store.operations.first.id;
    await store.approveSelectedTransfer(transferId);
    await store.completeSelectedTransfer(transferId);

    store.setDisposalWarehouse('wh-01');
    store.setDisposalProduct('p-02');
    store.setDisposalType(StockOperationType.damaged);
    store.setDisposalQuantity('1');
    await store.submitDamagedOrExpired();

    store.setHistoryFilter(StockOperationHistoryFilter.transfer);
    expect(
      store.filteredOperations.every(
        (e) => e.type == StockOperationType.transfer,
      ),
      isTrue,
    );

    store.setHistoryFilter(StockOperationHistoryFilter.damaged);
    expect(
      store.filteredOperations.every(
        (e) => e.type == StockOperationType.damaged,
      ),
      isTrue,
    );
  });
}
