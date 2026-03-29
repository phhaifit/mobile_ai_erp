import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';

class AuditRecord {
  final String id;
  final String warehouseId;
  final String warehouseName;
  final DateTime createdAt;
  final List<AuditLine> lines;
  final int totalMismatchCount;

  const AuditRecord({
    required this.id,
    required this.warehouseId,
    required this.warehouseName,
    required this.createdAt,
    required this.lines,
    required this.totalMismatchCount,
  });
}
