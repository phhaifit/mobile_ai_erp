class OutboundRecord {
  final String id;
  final String warehouseId;
  final String warehouseName;
  final String productId;
  final String productName;
  final int quantity;
  final String? note;
  final DateTime createdAt;

  const OutboundRecord({
    required this.id,
    required this.warehouseId,
    required this.warehouseName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.createdAt,
    this.note,
  });
}
