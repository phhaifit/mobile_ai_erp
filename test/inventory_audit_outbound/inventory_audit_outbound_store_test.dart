import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_audit_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_by_warehouse_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_outbound_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_warehouses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/save_inventory_audit_session_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/submit_inventory_outbound_usecase.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/models/inventory_workflow_view_models.dart';
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

  test('stocktake lifecycle transitions to approved', () async {
    expect(await store.openSession(), isTrue);
    expect(store.activeSession?.status, StocktakeSessionStatus.counting);

    for (final item in store.inventoryItems) {
      store.setPhysicalCount(item.productId, '${item.systemQty}');
    }

    expect(await store.submitCounts(), isTrue);
    expect(store.activeSession?.status, StocktakeSessionStatus.submitted);

    expect(await store.closeSession(), isTrue);
    expect(store.activeSession?.closedAt, isNotNull);

    expect(await store.reconcileSession(), isTrue);
    expect(store.activeSession?.status, StocktakeSessionStatus.reconciled);

    expect(await store.approveSession(), isTrue);
    expect(store.activeSession?.status, StocktakeSessionStatus.approved);
  });

  test('action gating blocks reconcile before close', () async {
    await store.openSession();
    for (final item in store.inventoryItems) {
      store.setPhysicalCount(item.productId, '${item.systemQty}');
    }
    await store.submitCounts();

    expect(store.canReconcileSession, isFalse);
    expect(store.reconcileSessionDisabledReason, contains('Close session'));
  });

  test('createOutboundIssue adds status-tracked issue', () async {
    final first = store.inventoryItems.first;
    store.setOutboundWarehouse(store.selectedWarehouseId);
    store.setOutboundProduct(first.productId);
    store.setOutboundQuantity('2');

    final success = await store.createOutboundIssue();

    expect(success, isTrue);
    expect(store.outboundIssues, isNotEmpty);
    expect(store.outboundIssues.first.status, OutboundIssueStatus.confirmed);
  });

  test('canCreateOutboundIssue false for invalid quantity', () {
    final first = store.inventoryItems.first;
    store.setOutboundWarehouse(store.selectedWarehouseId);
    store.setOutboundProduct(first.productId);
    store.setOutboundQuantity('${first.systemQty + 1}');

    expect(store.canCreateOutboundIssue, isFalse);
    expect(store.createOutboundDisabledReason, contains('exceeds'));
  });
}
