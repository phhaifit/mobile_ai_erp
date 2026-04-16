import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_warehouse.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';

abstract class InventoryAuditOutboundRepository {
  Future<List<InventoryWarehouse>> getWarehouses();

  Future<List<InventoryItem>> getInventoryByWarehouse(String warehouseId);

  Future<AuditRecord> openStocktakeSession({
    required String warehouseId,
  });

  Future<AuditRecord> submitStocktakeCounts({
    required String sessionId,
    required String warehouseId,
    required List<AuditLine> lines,
  });

  Future<AuditRecord> closeStocktakeSession({
    required String sessionId,
  });

  Future<AuditRecord> reconcileStocktakeSession({
    required String sessionId,
  });

  Future<AuditRecord> approveStocktakeSession({
    required String sessionId,
    required String approverName,
  });

  Future<List<AuditRecord>> getAuditRecords();

  Future<OutboundRecord> createOutboundIssue({
    required String warehouseId,
    required String productId,
    required int quantity,
    String? note,
  });

  Future<OutboundRecord> updateOutboundIssueStatus({
    required String outboundId,
    required String status,
  });

  Future<List<OutboundRecord>> getOutboundRecords();

  Future<AuditRecord> saveAuditSession({
    required String warehouseId,
    required List<AuditLine> lines,
  }) async {
    final opened = await openStocktakeSession(warehouseId: warehouseId);
    await submitStocktakeCounts(
      sessionId: opened.id,
      warehouseId: warehouseId,
      lines: lines,
    );
    await closeStocktakeSession(sessionId: opened.id);
    return reconcileStocktakeSession(sessionId: opened.id);
  }

  Future<OutboundRecord> submitOutbound({
    required String warehouseId,
    required String productId,
    required int quantity,
    String? note,
  }) {
    return createOutboundIssue(
      warehouseId: warehouseId,
      productId: productId,
      quantity: quantity,
      note: note,
    );
  }
}
