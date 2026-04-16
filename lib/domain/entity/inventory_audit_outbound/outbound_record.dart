class OutboundRecord {
  final String id;
  final String warehouseId;
  final String warehouseName;
  final String productId;
  final String productName;
  final int quantity;
  final String? note;
  final DateTime createdAt;
  final String status;
  final String? code;
  final DateTime? updatedAt;

  const OutboundRecord({
    required this.id,
    required this.warehouseId,
    required this.warehouseName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.createdAt,
    this.note,
    this.status = 'confirmed',
    this.code,
    this.updatedAt,
  });
}
