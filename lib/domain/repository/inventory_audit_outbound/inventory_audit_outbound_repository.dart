import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_warehouse.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';

abstract class InventoryAuditOutboundRepository {
  Future<List<InventoryWarehouse>> getWarehouses();

  Future<List<InventoryItem>> getInventoryByWarehouse(String warehouseId);

  Future<AuditRecord> saveAuditSession({
    required String warehouseId,
    required List<AuditLine> lines,
  });

  Future<List<AuditRecord>> getAuditRecords();

  Future<OutboundRecord> submitOutbound({
    required String warehouseId,
    required String productId,
    required int quantity,
    String? note,
  });

  Future<List<OutboundRecord>> getOutboundRecords();
}
