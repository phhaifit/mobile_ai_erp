import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/stock_operations/mock_stock_operations_repository.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/stock_operations_screen.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';

void main() {
  testWidgets('dashboard renders list on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = StockOperationsStore(MockStockOperationsRepository());

    await tester.pumpWidget(
      MaterialApp(home: StockOperationsScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Internal Transfer'), findsOneWidget);
    expect(find.text('Operation History'), findsOneWidget);
  });

  testWidgets('desktop shows navigation rail and dashboard panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = StockOperationsStore(MockStockOperationsRepository());

    await tester.pumpWidget(
      MaterialApp(home: StockOperationsScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Stock Operations Dashboard'), findsOneWidget);
  });
}
