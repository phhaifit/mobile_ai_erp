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
  testWidgets('audit screen renders mobile list under 600px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();

    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit_mobile_list')), findsOneWidget);
  });

  testWidgets('audit screen renders desktop side-by-side layout >= 600px', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();

    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit_desktop_list')), findsOneWidget);
    expect(find.text('Physical Count & Discrepancy'), findsOneWidget);
  });

  testWidgets('summary screen renders desktop table layout', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();
    await store.loadInitialData();
    store.setPhysicalCount(store.inventoryItems.first.productId, '99');
    await store.saveAuditSession();

    await tester.pumpWidget(
      MaterialApp(home: InventoryAuditSummaryScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit_summary_desktop_table')), findsOneWidget);
  });

  testWidgets('summary screen renders mobile card layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();
    await store.loadInitialData();
    store.setPhysicalCount(store.inventoryItems.first.productId, '99');
    await store.saveAuditSession();

    await tester.pumpWidget(
      MaterialApp(home: InventoryAuditSummaryScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit_summary_mobile_cards')), findsOneWidget);
  });

  testWidgets('outbound form disables submit when invalid', (tester) async {
    final store = _buildStore();

    await tester.pumpWidget(MaterialApp(home: InventoryOutboundScreen(store: store)));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('outbound_submit_button')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('outbound screen switches layout by breakpoint', (tester) async {
    final store = _buildStore();

    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(MaterialApp(home: InventoryOutboundScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('outbound_mobile_layout')), findsOneWidget);

    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpWidget(MaterialApp(home: InventoryOutboundScreen(store: store)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('outbound_desktop_layout')), findsOneWidget);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('audit screen app bar navigates to summary and outbound', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();
    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_audit_summary_button')));
    await tester.pumpAndSettle();
    expect(find.text('Inventory Audit Summary'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_outbound_button')));
    await tester.pumpAndSettle();
    expect(find.text('Outbound / Goods Issue'), findsOneWidget);
  });
}
