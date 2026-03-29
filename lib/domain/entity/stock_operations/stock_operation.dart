enum StockOperationType { transfer, damaged, expired }

enum StockOperationStatus { completed }

class StockOperation {
  final String id;
  final StockOperationType type;
  final StockOperationStatus status;
  final String productId;
  final String productName;
  final int quantity;
  final String? sourceWarehouseId;
  final String? sourceWarehouseName;
  final String? destinationWarehouseId;
  final String? destinationWarehouseName;
  final DateTime createdAt;
  final String? note;

  const StockOperation({
    required this.id,
    required this.type,
    required this.status,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.createdAt,
    this.sourceWarehouseId,
    this.sourceWarehouseName,
    this.destinationWarehouseId,
    this.destinationWarehouseName,
    this.note,
  });
}
