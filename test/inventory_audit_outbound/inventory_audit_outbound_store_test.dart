import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_audit_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_by_warehouse_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_outbound_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_warehouses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/save_inventory_audit_session_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/submit_inventory_outbound_usecase.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

void main() {
  late InventoryAuditOutboundStore store;

  setUp(() async {
    final InventoryAuditOutboundRepository repository =
        MockInventoryAuditOutboundRepository();
    store = InventoryAuditOutboundStore(
      GetInventoryWarehousesUseCase(repository),
      GetInventoryByWarehouseUseCase(repository),
      SaveInventoryAuditSessionUseCase(repository),
      GetInventoryAuditRecordsUseCase(repository),
      SubmitInventoryOutboundUseCase(repository),
      GetInventoryOutboundRecordsUseCase(repository),
    );
    await store.loadInitialData();
  });

  test('audit mismatch computation reflects physical vs system quantities', () {
    final first = store.inventoryItems.first;
    store.setPhysicalCount(first.productId, '${first.systemQty + 5}');

    expect(store.mismatchCount, 1);
    expect(store.totalAbsoluteDiscrepancy, 5);
  });

  test('save audit creates record and adjusts system quantity', () async {
    final first = store.inventoryItems.first;
    final before = first.systemQty;

    store.setPhysicalCount(first.productId, '${before - 4}');
    final saved = await store.saveAuditSession();

    expect(saved, isTrue);
    expect(store.auditRecords, isNotEmpty);

    final refreshed = store.inventoryItems.firstWhere(
      (item) => item.productId == first.productId,
    );
    expect(refreshed.systemQty, before - 4);
  });

  test('outbound validation blocks invalid quantities', () {
    final first = store.inventoryItems.first;

    store.setOutboundWarehouse(store.selectedWarehouseId);
    store.setOutboundProduct(first.productId);
    store.setOutboundQuantity('${first.systemQty + 1}');

    expect(store.canSubmitOutbound, isFalse);

    store.setOutboundQuantity('0');
    expect(store.canSubmitOutbound, isFalse);
  });

  test('successful outbound decrements stock and appends record', () async {
    final first = store.inventoryItems.first;
    final startQty = first.systemQty;

    store.setOutboundWarehouse(store.selectedWarehouseId);
    store.setOutboundProduct(first.productId);
    store.setOutboundQuantity('3');

    final success = await store.submitOutbound();

    expect(success, isTrue);
    expect(store.outboundRecords, isNotEmpty);

    final updated = store.inventoryItems.firstWhere(
      (item) => item.productId == first.productId,
    );
    expect(updated.systemQty, startQty - 3);
  });

  test('shared stock state between outbound and audit reads', () async {
    final first = store.inventoryItems.first;

    store.setOutboundWarehouse(store.selectedWarehouseId);
    store.setOutboundProduct(first.productId);
    store.setOutboundQuantity('2');
    await store.submitOutbound();

    final line = store.auditLines.firstWhere((line) => line.productId == first.productId);
    expect(line.systemQty, first.systemQty - 2);
  });
}
