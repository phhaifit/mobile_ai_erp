import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';

abstract class StockOperationsRepository {
  Future<List<Warehouse>> getWarehouses();

  Future<List<ProductStock>> getProductStocks();

  Future<List<StockOperation>> getOperations();

  Future<StockOperation> createTransfer({
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String productId,
    required int quantity,
  });

  Future<StockOperation> approveTransfer({required String transferId});

  Future<StockOperation> completeTransfer({required String transferId});

  Future<StockOperation> submitDamagedOrExpired({
    required String warehouseId,
    required String productId,
    required int quantity,
    required StockOperationType type,
    String? note,
  });
}
