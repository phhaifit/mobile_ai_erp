import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

void main() {
  testWidgets('inventory audit route smoke test', (WidgetTester tester) async {
    final store = InventoryAuditOutboundStore(
      MockInventoryAuditOutboundRepository(),
    );

    await tester.pumpWidget(MaterialApp(home: InventoryAuditScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('Inventory Audit'), findsOneWidget);
  });
}
