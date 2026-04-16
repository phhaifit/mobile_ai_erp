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
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_history_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
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

Future<void> _fillAllMainWarehouseCounts(
  WidgetTester tester,
  Map<String, String> values,
) async {
  await tester.enterText(
    find.byKey(const Key('mobile_input_wh-01_p-01')),
    values['p-01'] ?? '120',
  );
  await tester.enterText(
    find.byKey(const Key('mobile_input_wh-01_p-02')),
    values['p-02'] ?? '40',
  );
  await tester.enterText(
    find.byKey(const Key('mobile_input_wh-01_p-03')),
    values['p-03'] ?? '65',
  );
  await tester.pump();
}

void main() {
  testWidgets('audit screen renders lifecycle action bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();

    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit_open_session_button')), findsOneWidget);
    expect(find.byKey(const Key('audit_submit_counts_button')), findsOneWidget);
    expect(find.byType(WorkflowStepper), findsOneWidget);
  });

  testWidgets('submit counts remains disabled until all counts valid', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();

    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('audit_open_session_button')));
    await tester.pumpAndSettle();

    expect(store.canSubmitCounts, isFalse);

    await _fillAllMainWarehouseCounts(tester, const {
      'p-01': '120',
      'p-02': '40',
      'p-03': '65',
    });

    expect(store.canSubmitCounts, isTrue);
  });

  testWidgets('summary screen renders reconciliation list', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();
    await store.loadInitialData();
    await store.openSession();
    for (final item in store.inventoryItems) {
      store.setPhysicalCount(item.productId, '${item.systemQty}');
    }
    await store.submitCounts();
    await store.closeSession();
    await store.reconcileSession();

    await tester.pumpWidget(
      MaterialApp(home: InventoryAuditSummaryScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('audit_summary_mobile_cards')), findsOneWidget);
    expect(find.byType(WorkflowStatusBadge), findsWidgets);
  });

  testWidgets('outbound create and history render status badges', (tester) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = _buildStore();
    await tester.pumpWidget(MaterialApp(home: InventoryOutboundScreen(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('outbound_product_dropdown_wh-01')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A4 Paper Box (120)').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('outbound_qty_field_wh-01')), '3');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('outbound_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byType(WorkflowStatusBadge), findsWidgets);

    await tester.tap(find.byKey(const Key('open_outbound_history_button')));
    await tester.pumpAndSettle();
    expect(find.byType(InventoryOutboundHistoryScreen), findsOneWidget);
    expect(find.byType(WorkflowStatusBadge), findsWidgets);
  });

  testWidgets('audit screen app bar navigates to summary and outbound', (tester) async {
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

