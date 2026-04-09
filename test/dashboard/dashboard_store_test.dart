import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/data/repository/dashboard/mock_dashboard_repository.dart';
import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';
import 'package:mobile_ai_erp/presentation/dashboard/store/dashboard_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

void main() {
  group('DashboardStore', () {
    late DashboardStore store;

    setUp(() {
      store = DashboardStore(MockDashboardRepository(), ErrorStore());
    });

    tearDown(() {
      store.errorStore.dispose();
    });

    test('loads mock dashboard data', () async {
      await store.loadDashboard();

      expect(store.kpis, isNotEmpty);
      expect(store.pendingTasks, isNotEmpty);
      expect(store.salesSeries, isNotEmpty);
      expect(store.insights, isNotEmpty);
      expect(store.quickNavItems, isNotEmpty);
      expect(store.generatedAt, isNotNull);
    });

    test('changes period and refreshes trend data', () async {
      await store.setPeriod(DashboardPeriod.monthly);

      expect(store.period, DashboardPeriod.monthly);
      expect(store.salesSeries.length, 4);
    });

    test('computes pending counters', () async {
      await store.loadDashboard();

      expect(store.totalPending, greaterThan(0));
      expect(store.criticalPendingCount, greaterThanOrEqualTo(1));
    });

    test('sets error message when repository fails', () async {
      final failingStore = DashboardStore(_FailingDashboardRepository(), ErrorStore());
      addTearDown(() => failingStore.errorStore.dispose());

      await failingStore.loadDashboard();

      expect(failingStore.errorMessage, 'Unable to load dashboard');
      expect(failingStore.hasData, isFalse);
    });

    test('dashboard and suppliers routes are registered', () {
      expect(Routes.routes.containsKey(Routes.dashboard), isTrue);
      expect(Routes.routes.containsKey(Routes.suppliers), isTrue);
    });
  });
}

class _FailingDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSnapshot> loadDashboard(DashboardPeriod period) async {
    throw Exception('mock failure');
  }
}
