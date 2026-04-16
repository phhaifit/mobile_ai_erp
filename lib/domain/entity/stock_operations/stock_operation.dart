enum StockOperationType { transfer, damaged, expired }

enum StockOperationStatus { draft, approved, completed, cancelled }

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
  final String? createdBy;
  final String? approvedBy;
  final String? completedBy;
  final DateTime? approvedAt;
  final DateTime? completedAt;
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
    this.createdBy,
    this.approvedBy,
    this.completedBy,
    this.approvedAt,
    this.completedAt,
    this.note,
  });

  StockOperation copyWith({
    String? id,
    StockOperationType? type,
    StockOperationStatus? status,
    String? productId,
    String? productName,
    int? quantity,
    String? sourceWarehouseId,
    String? sourceWarehouseName,
    String? destinationWarehouseId,
    String? destinationWarehouseName,
    DateTime? createdAt,
    String? createdBy,
    String? approvedBy,
    String? completedBy,
    DateTime? approvedAt,
    DateTime? completedAt,
    String? note,
  }) {
    return StockOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
      sourceWarehouseName: sourceWarehouseName ?? this.sourceWarehouseName,
      destinationWarehouseId:
          destinationWarehouseId ?? this.destinationWarehouseId,
      destinationWarehouseName:
          destinationWarehouseName ?? this.destinationWarehouseName,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      completedBy: completedBy ?? this.completedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
    );
  }
}
