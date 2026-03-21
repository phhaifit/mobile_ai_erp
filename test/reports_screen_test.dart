import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/reports_analytics.dart';
import 'package:mobile_ai_erp/presentation/reports/store/reports_store.dart';

void main() {
  testWidgets('reports dashboard renders all primary sections', (tester) async {
    final store = ReportsStore(ReportsMockRepository(), ErrorStore());
    await store.loadDashboard();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: ReportsAnalyticsScreen(store: store),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Reports & Analytics'), findsAtLeastNWidgets(1));
    expect(find.text('Sales analytics'), findsOneWidget);
    expect(find.text('Product performance'), findsOneWidget);
    expect(find.text('Inventory reports'), findsOneWidget);
    expect(find.text('Financial report (P&L)'), findsOneWidget);
    expect(find.text('Data export center'), findsOneWidget);
  });

  testWidgets('reports screen adapts on narrow layout', (tester) async {
    final store = ReportsStore(ReportsMockRepository(), ErrorStore());
    await store.loadDashboard();

    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: ReportsAnalyticsScreen(store: store),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('Recent export jobs'), findsOneWidget);
  });
}
