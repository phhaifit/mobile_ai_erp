import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/model/reports_models.dart';
import 'package:mobile_ai_erp/presentation/reports/store/reports_store.dart';

void main() {
  group('ReportsStore', () {
    late ReportsStore store;

    setUp(() {
      store = ReportsStore(ReportsMockRepository(), ErrorStore());
    });

    test('loads dashboard mock data', () async {
      await store.loadDashboard();

      expect(store.dashboard, isNotNull);
      expect(store.dashboard!.salesKpis, isNotEmpty);
      expect(store.dashboard!.exportJobs, isNotEmpty);
    });

    test('changes filter period and updates data', () async {
      await store.changePeriod(ReportPeriod.quarterly);

      expect(store.selectedFilter.period, ReportPeriod.quarterly);
      expect(store.dashboard, isNotNull);
      expect(store.dashboard!.trendPoints.length, 3);
    });

    test('export marks a job as completed', () async {
      await store.loadDashboard();

      await store.exportJob(1);

      expect(
        store.dashboard!.exportJobs[1].status,
        ExportJobStatus.completed,
      );
    });
  });
}
