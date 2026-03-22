import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_audit_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_by_warehouse_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_outbound_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_warehouses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/save_inventory_audit_session_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/submit_inventory_outbound_usecase.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_summary_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

InventoryAuditOutboundStore _buildStore() {
  final InventoryAuditOutboundRepository repository =
      MockInventoryAuditOutboundRepository();
  return InventoryAuditOutboundStore(
    GetInventoryWarehousesUseCase(repository),
    GetInventoryByWarehouseUseCase(repository),
    SaveInventoryAuditSessionUseCase(repository),
    GetInventoryAuditRecordsUseCase(repository),
    SubmitInventoryOutboundUseCase(repository),
    GetInventoryOutboundRecordsUseCase(repository),
  );
}

void main() {
  testWidgets('inventory audit route smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();

    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('Inventory Audit'), findsOneWidget);
  });

  testWidgets('inventory audit summary route smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();
    await store.loadInitialData();

    await tester.pumpWidget(
      MaterialApp(home: InventoryAuditSummaryScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventory Audit Summary'), findsOneWidget);
  });

  testWidgets('inventory outbound route smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();

    await tester.pumpWidget(
      MaterialApp(home: InventoryOutboundScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Outbound / Goods Issue'), findsOneWidget);
  });
}
