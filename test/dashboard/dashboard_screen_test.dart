import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/data/repository/dashboard/mock_dashboard_repository.dart';
import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';
import 'package:mobile_ai_erp/presentation/dashboard/dashboard_screen.dart';
import 'package:mobile_ai_erp/presentation/dashboard/store/dashboard_store.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

void main() {
  DashboardStore createStore() {
    return DashboardStore(MockDashboardRepository(), ErrorStore());
  }

  testWidgets('renders dashboard sections on mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = createStore();
    addTearDown(() => store.errorStore.dispose());

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Business Health Overview'), findsOneWidget);
    expect(find.text('Pending Tasks'), findsOneWidget);
    expect(find.text('Real-Time Sales'), findsOneWidget);
    expect(find.text('Smart Insights Feed'), findsOneWidget);
    expect(find.text('Quick Navigation'), findsOneWidget);
  });

  testWidgets('renders dashboard sections on desktop', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = createStore();
    addTearDown(() => store.errorStore.dispose());

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Business Dashboard'), findsOneWidget);
    expect(find.text('Business Health Overview'), findsOneWidget);
    expect(find.text('Pending Tasks'), findsOneWidget);
  });

  testWidgets('quick navigation routes to products', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = createStore();
    addTearDown(() => store.errorStore.dispose());

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          Routes.productManagementList: (_) => const Scaffold(
                body: Text('Products Screen'),
              ),
        },
        home: DashboardScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    final productsChip = find.textContaining('Products');
    await tester.scrollUntilVisible(productsChip, 200);
    await tester.tap(productsChip);
    await tester.pumpAndSettle();

    expect(find.text('Products Screen'), findsOneWidget);
  });

  testWidgets('shows error state and retry action on load failure', (tester) async {
    final store = DashboardStore(_FailingDashboardRepository(), ErrorStore());
    addTearDown(() => store.errorStore.dispose());

    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load dashboard'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
  });
}

class _FailingDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSnapshot> loadDashboard(DashboardPeriod period) async {
    throw Exception('mock failure');
  }
}
