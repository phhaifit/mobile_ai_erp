import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/stock_operations/mock_stock_operations_repository.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/stock_operations_screen.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';

void main() {
  testWidgets('stock operations screen smoke test', (WidgetTester tester) async {
    final store = StockOperationsStore(MockStockOperationsRepository());

    await tester.pumpWidget(
      MaterialApp(home: StockOperationsScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stock Operations'), findsWidgets);
  });
}
