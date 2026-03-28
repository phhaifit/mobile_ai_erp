class AuditLine {
  final String productId;
  final String productName;
  final int systemQty;
  final int physicalQty;
  final int discrepancy;
  final String unit;

  const AuditLine({
    required this.productId,
    required this.productName,
    required this.systemQty,
    required this.physicalQty,
    required this.discrepancy,
    this.unit = 'pcs',
  });
}
