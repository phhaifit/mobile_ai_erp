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

    expect(find.text('Internal Stock Transfer'), findsOneWidget);
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

  testWidgets('transfer screen is vertical on mobile and split on desktop', (
    tester,
  ) async {
    final store = StockOperationsStore(MockStockOperationsRepository());

    tester.view.physicalSize = const Size(599, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(MaterialApp(home: StockOperationsScreen(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Internal Stock Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1: Transfer Details'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpWidget(MaterialApp(home: StockOperationsScreen(store: store)));
    await tester.pumpAndSettle();
    store.setCurrentView(StockOperationsView.transfer);
    await tester.pumpAndSettle();
    expect(find.text('Internal Stock Transfer'), findsOneWidget);
    expect(find.text('Stock Preview'), findsOneWidget);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('history renders cards on mobile and table on desktop', (tester) async {
    final store = StockOperationsStore(MockStockOperationsRepository());

    tester.view.physicalSize = const Size(599, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(MaterialApp(home: StockOperationsScreen(store: store)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Operation History'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Qty:'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpWidget(MaterialApp(home: StockOperationsScreen(store: store)));
    await tester.pumpAndSettle();
    store.setCurrentView(StockOperationsView.history);
    await tester.pumpAndSettle();
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('desktop rail selection updates detail panel content', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = StockOperationsStore(MockStockOperationsRepository());
    await tester.pumpWidget(MaterialApp(home: StockOperationsScreen(store: store)));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Transfer'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stock Preview'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('History'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Warehouses'), findsOneWidget);
  });

  testWidgets(
    'changing source refreshes destination options and clears stale destination',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final store = StockOperationsStore(MockStockOperationsRepository());
      await tester.pumpWidget(MaterialApp(home: StockOperationsScreen(store: store)));
      await tester.pumpAndSettle();

      store.setCurrentView(StockOperationsView.transfer);
      await tester.pumpAndSettle();

      // Simulate UI source changes.
      store.setTransferSourceWarehouse('wh-02');
      await tester.pumpAndSettle();

      final destinationDropdownAfterNorth = tester.widget<DropdownButton<String>>(
        find.descendant(
          of: find.byKey(const Key('transfer_destination_dropdown')),
          matching: find.byType(DropdownButton<String>),
        ),
      );
      final destinationValuesAfterNorth = destinationDropdownAfterNorth.items
              ?.map((e) => e.value)
              .whereType<String>()
              .toList(growable: false) ??
          const <String>[];
      expect(destinationValuesAfterNorth.contains('wh-01'), isTrue);
      expect(destinationValuesAfterNorth.contains('wh-02'), isFalse);

      // Main can be selected when source is North.
      store.setTransferDestinationWarehouse('wh-01');
      await tester.pumpAndSettle();
      expect(store.transferDestinationWarehouseId, 'wh-01');

      // Changing source clears stale destination.
      store.setTransferSourceWarehouse('wh-03');
      await tester.pumpAndSettle();
      expect(store.transferDestinationWarehouseId, isNull);
    },
  );
}
