import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_summary_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

void main() {
  testWidgets('audit screen renders mobile list under 600px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = InventoryAuditOutboundStore(
      MockInventoryAuditOutboundRepository(),
    );

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

    final store = InventoryAuditOutboundStore(
      MockInventoryAuditOutboundRepository(),
    );

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

    final store = InventoryAuditOutboundStore(
      MockInventoryAuditOutboundRepository(),
    );
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

    final store = InventoryAuditOutboundStore(
      MockInventoryAuditOutboundRepository(),
    );
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
    final store = InventoryAuditOutboundStore(
      MockInventoryAuditOutboundRepository(),
    );

    await tester.pumpWidget(MaterialApp(home: InventoryOutboundScreen(store: store)));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('outbound_submit_button')),
    );
    expect(button.onPressed, isNull);
  });
}
